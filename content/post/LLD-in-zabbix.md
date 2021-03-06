+++
title = "LLD in zabbix"
date = "2016-07-30T14:09:58+08:00"
tags = ["zabbix", "monitor"]
description = ""
+++

如果需要监控的内容比较多的时候，手动管理报警信息就已经不使用了，加一批机器就需要忙活一阵子。也不能体现我们充满智慧的大脑的作用。

zabbix 支持 LLD(low level discovery) 方式来自动产生监控项目，包括 item, trigger 这些都可以自动添加。大概讲解一下可以利用这个东西做什么事情。

## zabbix 收集数据的方式

zabbix 有很多收集数据的方法，这里重点讲 2 个，一个是 `zabbix agent`，一个是 `zabbix traper`。这两个方式可以和 nagios 里面的 active 和 passive 方式做类比。traaper 方式对应的就是 passive，就是 client 主动发送数据给 server。

对于 zabbix agent 方式，我们可以自己定义一些 `userParameter` 来添加自定义监控，这些网上很多例子。如果使用 trapper 方式，那么原则上面可以不用做任何自定义，就可以通过 zabbix-sender 或者自己模拟 sender 的协议，通过比如 python，java 等发送自己的监控信息。通过 python 发送的例子网上也有。

## LLD

参考[这里](https://www.zabbix.com/documentation/3.2/manual/discovery/low_level_discovery)，LLD 主要的思路就是给服务器端发送一个 json 数据格式。例如下面这个。

```
{
  "data":[
  
  { "{#FSNAME}":"/",                           "{#FSTYPE}":"rootfs"   },
  { "{#FSNAME}":"/sys",                        "{#FSTYPE}":"sysfs"    },
  { "{#FSNAME}":"/proc",                       "{#FSTYPE}":"proc"     },
  { "{#FSNAME}":"/dev",                        "{#FSTYPE}":"devtmpfs" },
  { "{#FSNAME}":"/dev/pts",                    "{#FSTYPE}":"devpts"   },
  { "{#FSNAME}":"/lib/init/rw",                "{#FSTYPE}":"tmpfs"    },
  { "{#FSNAME}":"/dev/shm",                    "{#FSTYPE}":"tmpfs"    },
  { "{#FSNAME}":"/home",                       "{#FSTYPE}":"ext3"     },
  { "{#FSNAME}":"/tmp",                        "{#FSTYPE}":"ext3"     },
  { "{#FSNAME}":"/usr",                        "{#FSTYPE}":"ext3"     },
  { "{#FSNAME}":"/var",                        "{#FSTYPE}":"ext3"     },
  { "{#FSNAME}":"/sys/fs/fuse/connections",    "{#FSTYPE}":"fusectl"  }
  
  ]
}
```

这个数据里面，data 是必须的，里面包含里面发现的可监控数据，这可以是任何数据。例子里面是发现了可以用来监控的磁盘分区。data 是个数组，每个可监控项是一个数组元素。还有类似下面这样的数据。

```
{
    "data": [
        {
            "{#HOST}": "Japan 1",
            "{#COUNT}": "5"
        },
        {
            "{#HOST}": "Japan 2",
            "{#COUNT}": "12"
        },
        {
            "{#HOST}": "Latvia",
            "{#COUNT}": "3"
        }
    ]
}
```

这个是发现了一些可监控的 host。

理解没有？发现是发现可监控的服务，并不是发现监控项。比如我们可以通过发现这机器上面有没有启动 ssh，发现有启动之后，我们就可以通过服务器端配置 discovery 自动添加一些监控规则。

```
{
    "data": [
        { "{#SSH_PORT}": "22" },
        { "{#SSH_PORT}": "8022" }
    ]
}
```

比如上面这个，我们发现了 2 个 ssh 进程，一个是 22 端口，一个是 8022 端口。

所以重点是发现有什么可监控的服务，并不是发现监控项。

BUT，其实并不是不能发现监控项，也是可以的。不过是，这种被发现的监控项，除非对应的 trigger 也都是一样的，否则你会发现无法分别添加不同的 trigger 规则。

## 发现监控项

有了发现服务之后，就肯定需要对相应的服务的一些监控项做监控了。这个给 discovery 规则配置 item prototype 就可以了，不过这个里面有点坑需要填，后面会说，这里先不讲。

那么比如对于 ssh 服务，可以监控
* 当前链接人数，conn.cnt
* 配置文件的 md5，conf.md5（配合 zabbix trigger 可以用来监控文件是不是被修改了）

那监控数据就如下面

```
{
    "22.conn.cnt": 4,
    "22.conf.md5": "18492113fb263c9d0a33c9fea403eea1",
    "8022.conn.cnt": 9,
    "8022.conf.md5": "6cab272daa07202ccb57c4064c0dcfb8"
}
```
上面就是一个 discovery 项目，filter 是 {% raw %}{#SSH_PORT}{% endraw %}，和 2 个 item prototype，分别是 {% raw %}{#SSH_PORT}.cnn.cnt{% endraw %} 和 {% raw %}{#SSH_PORT}.conf.md5{% endraw %}。

## 复杂一点的 LLD

一个 LLD 还可以发现多个服务。比如下面这种。

```
{
    "data": [
        { "{#SSH_PORT}": "22" },
        { "{#SSH_PORT}": "8022" },
        { "{#PG_PORT}": 5432 },
        { "{#PG_PORT}": 6432 }
    ]
}
```

这个除了我们前面讲的 ssh 服务，还发现了两个 pg 的服务。在服务器端，只需要添加两个 discovery 规则就可以了，分别使用 {% raw %}{#SSH_PORT}{% endraw %} 和 {% raw %}{#PG_PORT}{% endraw %} 这两个宏来过滤数据。

```
{
    "data": [
        { "{#SSH_PORT}": "22" },
        { "{#SSH_PORT}": "8022" },
        { "{#PG_PORT}": 5432 },
        { "{#PG_PORT}": 6432 }
        { "{#MASTER_DB_PORT}": 5432, "{#SLAVE_DB}": "host1" },
        { "{#MASTER_DB_PORT}": 5432, "{#SLAVE_DB}": "host2" },
    ]
}
```

上面这个，除了有 2 个 db 之外，还有一个 db 是个 master，能看到他对应的 slave 有哪些。要注意，我们在新增加的这个发现项里面，不能再使用 {% raw %}{#PG_PORT}{% endraw %} 这个宏了，因为如果使用了这个宏，就会和第3，4个项目无法区分了。所以我们改了一下名字。

到此为止，只是我们的构思，想要告诉 zabbix 我们想要监控什么。真正使用还需要走一些路。

## 如何发送数据

不管是 discovery 数据，还是 item 的监控数据，都可以通过 agent 和 trapper 方式发送。

对于 discovery 数据，使用 agent 发送就是上面讲的格式。

```
{
    "data": [
        { "{#PG.OTHER}": "0" },
     ]
}
```

如果使用 trapper 方式发送，格式如下

```
{
    "data": [
        {
            "host": "HOST1",
            "value": "{\"data\": [{\"{#PG.OTHER}\": \"0\"}]}",
            "key": "pg.discover"
        }
    ],
    "request": "sender data"
}
```
上面这个数据里面，data 和 request 是 zabbix sender 的固定格式。data 里面，包含了 host, value, key 三个字段。host 是被监控的 host，和将来服务器端的 host 对应。value 是发送的监控内容，可以看到也就是我们使用 agent 发送的内容。key 就是对应的监控项，这个监控项也就是 agent 方式发送对应的那个 userParameter。

使用 trapper 方式发送里面，是可以伪造被监控的 host 的，所以 trapper 方式并不要求一定要在被监控机器上面执行。

对于 item 监控数据，使用 agent 发送是下面这种格式。

```
{
    "key1": 2,
    "key2": "ok"
}
```

使用 trapper 方式发送，是下面的这种格式。

```
{
    "data": [
        {
            "host": "HOST1",
            "value": 1,
            "key": "key1"
        },
        {
            "host": "HOST1",
            "value": "ok",
            "key": "key2"
        }
    ],
    "request": "sender data"
}
```


## zabbix 里面的限制

上面的例子很完美，但实际上 zabbix 是有一些限制的。比如 item 定义。

假如对于发现的 pg 服务，有一个监控项是连接数，比如 {% raw %}{#PG_PORT}.conn.cnt{% endraw %}，此时你会发现在 zabbix 新建 item 的 `Key` 那个设置里面，这么写无法提交。需要使用假装类似 userParameter 的方式来写，比如 {% raw %}pg.[{#PG.PORT}.conn.cnt]{% endraw %}，假装那个 `pg.` 是个 userParameter 命令，{% raw %}[{#PG.PORT}.conn.cnt]{% endraw %} 里面的内容是他的参数。当然，这个 pg. 可以基本可以是任何字符串，比如 abc，你自己觉得有意义就好了。

那么这个时候对于发现那块，我们基本不用动，需要动的是被发送的服务的监控项的命名上面。

比如以那个 ssh 的监控为例，原来发送的数据如下

```
{
    "22.conn.cnt": 4,
    "22.conf.md5": "18492113fb263c9d0a33c9fea403eea1",
    "8022.conn.cnt": 9,
    "8022.conf.md5": "6cab272daa07202ccb57c4064c0dcfb8"
}
```

我们只需要修改成这样

```
{
    "ssh[22.conn.cnt]": 4,
    "ssh[22.conf.md5]": "18492113fb263c9d0a33c9fea403eea1",
    "ssh[8022.conn.cnt]": 9,
    "ssh[8022.conf.md5]": "6cab272daa07202ccb57c4064c0dcfb8"
}
```

对应的 2 个 item prototype，key 分别修改为 {% raw %}ssh[{#SSH_PORT}.cnn.cnt]{% endraw %} 和 {% raw %}ssh[{#SSH_PORT}.conf.md5]{% endraw %}。那个 ssh 可以随意起。并且其实并不一定就得是这种模式，比如叫做 {% raw %}ssh.conf.md5[{#SSH_PORT}]{% endraw %} 应该也可以，当然需要你发送的数据也做对应修改。

## 如何发送监控数据

咦？好像说过一次了？这次和上面不一样，呵呵。

设计好并写好监控之后，选择什么方式发送监控数据呢。我选择的是 discovery 数据通过 agent 方式获取，也就是在各服务器上面定义相同的一个 key，然后执行这个 key 的时候发送发现的服务信息。

而对于监控项数据则通过 trapper 方式发送。通过 trapper 方式发送，需要定时执行，可以通过 crontab 发送。我选择的是建立了一个 agent 类型的 item，执行这个 item 的时候发送监控数据。这样一方面可以针对这个发送动作建立一个监控，另外一方面调整很方便，zabbix 界面修改就可以。并且我把这个 item 建立到了模板上面，只要修改应用模板就可以了。

监控数据也可以用 agent 方式发送，如果用 agent 方式发送，对于上面的 ssh 服务，就需要真的建立那个 ssh 的 userParameter 了，然后接受比如 `22.conf.md5` 这样的参数，去返回对应的监控数据。我没有用这种方式，是因为这样做等于有多少个 item 就需要在监控周期内执行多少次那个命令，给服务器增加负担（虽然没多少）。而使用 trapper 方式的话，就可以一次把所有的监控数据都发过去了，命令只需要执行一次。

## 如何应对不同的部分

到此为止，应该可以很完美的发现服务，并且监控了。但是会发现其实并不是所有服务器的服务都是一样的，比如对于 pgsql，slow query 的界定对于不同的业务可能不一样。而因为 trigger 也是自动发现添加的，这样也有可能需要不同的机器上面的服务有不同的阈值，怎么解决呢？

先说监控项的阈值。因为我的监控数据其实是通过建立一个 agent 类型的 item 定期发送 trapper 数据来实现的，所以只需要在调用那个 item 的时候传送不同的阈值就可以了。实际上面我的 itme key 定义是这样的 `pg.sendtrap[{$PG.DISCOVER.SETTINGS}]` 。那个 pg.sendtrap 是对应到一个 userParameter 的 `UserParameter=pg.sendtrap[*],/etc/zabbix/bin/zabbix_pg.py --check --sendtrap --settings $1`，在 zabbix_pg.py 里面，会处理 settings 参数。如果有阈值，那就定义好 `{$PG.DISCOVER.SETTINGS}` 这个宏就可以了。template 上面可以定义默认的阈值，当然默认阈值在程序里面定义也可以。然后不同 host 可以定义 host 的阈值，会覆盖模板的配置。

其实 trigger 的阈值和这个思路类似，也是 template 里面定义一个宏，trigger 里面使用这个宏就可以了。如果 host 有不同的阈值，那就定义一个 host 的宏覆盖他就可以了。

## 目前的情况

配合 zabbix 的 auto registration 这个 action，可以做到新机器只需要执行一个 saltstack state，安装好我们的 zabbix agent，就可以自动注册 host，自动添加监控报警。

相当完美。
