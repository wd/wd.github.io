+++
title = "Full page write in PostgreSQL"
date = "2016-12-08T18:02:14+08:00"
tags = ["postgresql"]
description = ""
+++


读了一篇[文章](http://blog.2ndquadrant.com/on-the-impact-of-full-page-writes/)，简单翻译总结下。

## Partial Writes / Torn Pages

pg 默认是 8kB 一个 page。linux 文件系统一般是 4kB（x86 里面最大是 4kB)，老设备驱动一般是 512B 一个扇区，新的设备有些支持 4kB 或者 8kB。

当 pg 写入一个 page 8kB 的时候，系统的底层会拆分小一点块，这里涉及到写入的原子性。8kB 的 pg page，会被文件系统拆分成 4kB 的块，然后拆分成 512B 扇区大小。这个时候如果系统崩溃（比如停电，内核 bug）会发生什么？

即使系统的存储有针对这种情况的设计（比如 SSD 自带电容器，RAID 控制器自带电池），内核那块也是会拆分成 4kB 的 page，所以还是有一定可能性，pg 写了 8kB，但是只有部分写入成功。

这个时候你可能意识到这就是为啥我们要有事务日志（WAL）。所以当系统崩溃重启之后，数据库会读取 WAL（从最后一次 checkpoint），然后重新写入一遍，以保证数据文件是完整的。

恢复的时候，在修改一个 page 之前，还是会读取一下。

在 checkpoint 之后第一次修改一个 page 的时候，会把整个 page 写入 WAL。这是为了保证在恢复的时候，能保证这些被修改的 page 能完全恢复到他原有的样子。

## 写放大

如果打开 Full page write，很显然会导致 WAL 文件增加，因为就算修改一个字节，也会导致 8kB page 的写入。因为 Full page write 只发生在 checkpoint 之后的第一次写入，所以减少 checkpoint 的发生频率是可以减少写入的。

## UUID vs BIGSERIAL 主键

比较了一下使用 UUID 或者 bigserial 做主键对写入的影响。可以看原链接的图，会发现在 INSERT 语句的情况下 UUID 产生的 WAL 文件量比较多。主要原因是 Btree 索引的情况下，bigserial 是顺序的维护这个索引，UUID 是无顺序的，会导致维护索引产生的数据量不同。

如果是使用 UPDATE 随机修改，那么会发现产生的 WAL 数量就差不多了。

## 8kB and 4kB pages

如果减小 pg 的 page 的大小，可以减小 WAL 数量。从 8kB 减小到 4kB，上面 UUID 那个例子，可以减少大概 35% 的量。

## 需要 full-page write 吗？

首先，这个参数是 2005 年 pg 8.1 引入的，那么现代的文件系统是不是已经不用操心部分写入的情况了？作者尝试了一些测试没有测试出来部分写入的情况，当然这不表示不会存在。但是就算是存在，数据的一致性校验也会是有效的保护（虽然并不能修复这个问题，但是至少能让你知道有坏的 page）

其次，现在很多系统都依赖于流式同步，并不会等着有问题的服务器在有硬件问题的时候重启，并且花费很多时间恢复，一般都直接切换到热备服务器上面了。这个时候部分写就不是什么问题了。但是如果我们都推荐这么做，那么「我也不知道为啥数据损坏了，我只是设置了 full\_page\_writes=off」这种会是 DBA 死前最常见的言论了。(类似于「这种蛇我之前在 reddit 看见过，无毒的」)

## 总结

对于 full-page write 你没法直接优化。大部分情况下，full-page write 都是发生在 checkpoint 之后，直到下一次 checkpoint。所以调整 checkpoint 的发生频率不要太频繁很重要。

有些应用层的操作，可能会导致对表或者索引的随机写入的增加，例如上面的 UUID 的值就是随机的，会让简单的 INSERT 也会导致索引的随机 update。使用 Bigserial 做主键(让 UUID 做替代键)可以减少写放大。


