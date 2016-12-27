title: Beansdb merge tools
date: 2016-12-26 18:36:11
tags:
  - beansdb
---

Beansdb 是豆瓣开源出来的一个高效的支持 memcached 协议的文件存储 db。按 key 查找的时候，会有索引定位到磁盘位置。不过貌似前段时间看到说他们搞了一个新的替代这个，我找了一下没找到链接。

使用 beansdb 的时候，有 2 个问题需要解决
* 冗余问题
* 数据过期删除问题

## 数据冗余问题

先说第一个问题。beansdb 本身不提供分布式 hash 逻辑，它就是个单机的程序。冗余需要你自己搞定，如果你使用标准的 memcache 协议，可以有多 server 的配置，读的时候其中一个失败会自动找下一个 server，写的时候就不会了，需要你自己写到多个 server。如果你所有的 server 都是一模一样的，那多写就可以了。如果不一样，你还需要考虑自己的 hash 策略。

豆瓣提供了一个 python 的[客户端](https://github.com/douban/beansdb/blob/master/python/dbclient.py)，这个客户端里面其实包含了 hash 策略。通过把 key 和 server 分桶来做 hash。摘一点代码如下

```
BEANSDBCFG = {
    "localhost:7901": range(16),
    "localhost:7902": range(16),
    "localhost:7903": range(16),
}

db = Beansdb(BEANSDBCFG, 16)
```
上面定义了三个 server，每个包含 16 个桶（你可以根据你的需求比如定义第一个 server 只包含某些桶）。

    def __init__(self, servers, buckets_count=16, N=3, W=1, R=1):

这里是定义写入数据的时候的逻辑，那个 `buckets_count` 是桶的数量，`N` 和 `R` 貌似没用。。。，`W` 是改动的时候要求成功的最小 server 数量，包括删除和写入的时候。

读取的时候，会循环从包含这个 key 的桶的 server 列表里面循环读取，这里还有一个「自愈」的逻辑，循环读取直到遇到一个成功的 server，会同时把前面失败的 server 都写入一份数据。

这样下来基本就解决了读写分布式和故障恢复的逻辑了，非常巧妙。

其实针对这个问题，豆瓣还开源了个 [beanseye](https://github.com/douban/beanseye)，具体功能没有仔细研究，不过应该是上面需要客户端处理的事情都不需要考虑了。

我们开始用的时候，不知道有 beanseye，我的场景是在 perl 环境下面使用，把 python 的客户端翻译了一个 perl 的版本出来。[1] 有兴趣可以看看。

## 数据过期删除问题

beansdb 设计之初写入用的是 append 模式，就是说，遇到删除也是写入一条新的记录，并不会返回去修改原来的数据，所以能达到合理的 IO 速度。如果场景是大量不会删除的小文件，那么 beansdb 使用起来非常合适。

如果有数据过期或者删除的需求，就需要想办法处理这些数据了，否则的话，beandb 的数据文件里面会慢慢的有大量的无用数据，浪费磁盘空间。

这个删除过期数据的过程，我看豆瓣叫做 merge。思路其实就是把所有数据遍历一次，把有效的数据写入一个新的 data 文件，然后旧的删掉，就可以了。beansdb 的数据文件有 2 种，一种是 `xxx.data`，这种文件是数据文件，另外一种是 `xxx.hint.qlz` 这种是索引文件。

针对这个需求，我写了两版程序，第一版就是单纯的解读一下数据文件，把其中的数据的信息读出来，主要是版本号和创建时间，然后根据版本号只写入高版本的，根据创建时间把过期的数据丢弃。生成新的 data 文件之后，要删除 hint 文件，启动的时候会自动产生 hint 文件。然后在 beansdb 的机器上面定期跑这个脚本就好了，注意跑之前应该先关闭 beansdb。

第一个版本的程序只是解读了每个块的数据头，程序用起来也勉强还行，但是主要问题是，每次启动都需要重新产生 hint 文件，导致启动到提供服务很慢，所以就有了第二版程序。第二版包含了第一版的全部功能，还提供了按照文件大小来定义删除时限的功能。

第二个版本程序基本把 data 和 hint 文件产生的逻辑都用 perl 实现了（不过还没有经过太多测试）。下面简单讲讲逻辑。

### data 文件

``` cpp
‌typedef struct data_record
{
    char *value;
    union
    {
        bool free_value;    // free value or not
        uint32_t crc;
    };
    int32_t tstamp;
    int32_t flag;
    int32_t version;
    uint32_t ksz;
    uint32_t vsz;
    char key[0];
‌} DataRecord;
```

数据文件里面，每个 key 对应的数据的长度是 `4*6 + key_size + value_size + padding`。

    read($fh, my $header, 4*6);
    my ( $crc, $tstamp, $flag, $ver, $ksz, $vsz ) = unpack('I i i i I I', $header);

头部是 24 个字节，依次包括校验数据，写入时间戳，标记位，版本号，key 的长度，value 的长度。上面 `unpack` 方法第一个参数里面的含义，可以参考[perl 的文档](http://perldoc.perl.org/functions/pack.html)。每个 4 字节，32bit 整数。

然后是读取 `$ksz` 的长度的 key，读取 `$vsz` 长度 value。如果 `$flag` 标记表明 value 有压缩，压缩用的是 QLZ 算法，真实的值需要用 qlz 解压缩之后才能得到。

最后是 padding 部分，整个数据长度需要是 256 的整数倍。不足的部分，会写入 `\0` 做 padding。

merge 的过程不关心 value 的真实值，所以不需要解压缩，把读取到的原样写回去就可以了。另外就是 merge 的时候遇到同一个 key 多个 version 出现的时候，只保留大的那个就可以了。这样操作之后 data 文件会变小。

### hint 文件

``` cpp
‌typedef struct hint_record
{
    uint32_t ksize:8;
    uint32_t pos:24;
    int32_t version;
    uint16_t hash;
    char key[NAME_IN_RECORD]; // allign
‌} HintRecord;
```

hint 文件比 data 文件稍微复杂一点，每一条记录是 `key_size + data_pos + ver + hash + key + padding`。

    my ( $ksz, $datapos, $ver, $hash ) = unpack("B8 B24 i B16", $header);

    $ksz = unpack("I", pack("B32", $ksz));
    $datapos = unpack("I", pack("B32", $datapos));
    $datapos = $datapos << 8;
    $hash = unpack("I", pack("B32", $hash));

头部的 10 个字节如上面代码，第一个 8 bit 是 key 的长度，接下来 24 个 bit 是这个 key 对应数据在 data 文件里面的位置。然后是 4 字节版本，16 bit 的 hash。

padding 和上面 data 里面的逻辑一样，按照 256 的倍数补全。

hint 文件结尾有个 `.qlz`，表示整个 hint 里面的数据是压缩的，所以在处理前需要先解压缩一下。（不过我看到我代码里面在读取 hint 的时候，是全部数据解压，写入的时候，是按照 record 压缩的，很奇怪）。
