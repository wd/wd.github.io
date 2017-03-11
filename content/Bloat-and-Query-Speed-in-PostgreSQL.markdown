+++
title = "Bloat and Query Speed in PostgreSQL"
date = "2016-12-09T12:12:21+08:00"
tags = ["postgresql"]
description = ""
+++


内容反义自 https://www.citusdata.com/blog/2016/11/04/autovacuum-not-the-enemy/

pg 的 mvcc 会导致表索引的 bloat 就不多说了。说一下不合理处理这种 bloat 害处是啥。

首先肯定是会浪费空间。然后也会影响查询速度。表和索引存储的时候都是 8kB 一个 page，如果一个查询一些行，数据库会加载这些 pages 到内存。一个 page 里面的 dead rows 越多，在加载的时候就越浪费 I/O。例如全表扫描会加载所有的 dead rows。

Bloat 还会导致热门的查询会一下塞满内存。会导致相同的 live rows 需要更多 pages。This causes swapping and makes certain query plans and algorithms ineligible for execution.

还有一个影响是，pg 的系统表也会有可能 bloat，因为他们也是表。导致这个的一种情况是频繁的创建和删除临时表。这个进一步会导致一些管理命令执行变慢，甚至比如 `\d` 这种命令。

索引也有可能会 bloat。索引是 tuple 标识和数据之间的一个映射。这些标识指向的是某个 page 里面的 offset。每个 tuple 都是一个独立的对象，需要自己的索引条目。更新一行的时候总是会创建这行的新的索引条目。

索引的 bloat 的影响比 table 小一点。索引里面指向 dead tuple 的可以直接标记为 dead. 这会使得索引膨胀，但是不会导致不必要的堆查找。同时更新堆中的 tuples 不影响已经索引的列，使用一种叫做 HOT 的技术来把指向 dead tuples 的指针指向新的。这允许查询可以通过这些指针复用旧的索引条目。(Also updates to tuples in the heap that do not affect the indexed column(s) use a technique called HOT to provide pointers from the dead tuple to its replacement. This allows queries to reuses old index entries by following pointers across the heap.) (没太看明白.)

索引 bloat 的问题还是应该需要重视。例如 btree 索引是由二叉树组成()。叶子节点包含值和 tuple 标识（应该是指在 data file 的 offset）。随机更新因为会重用 page，所以可以保持 btree 维持一个良好的形状。但是，如果是单侧更新，会导致大量的空页。

The size considerations of index bloat are still significant. For instance a btree index consists of binary tree of pages (the same sized pages as you find holding tuples in the heap). The leaf node pages contain values and tuple identifiers. Uniform random table updates tend to keep a btree index in pretty good shape because it can reuse pages. However lopsided inserts/updates affecting one side of the tree while preserving a few straggling entries can lead to lots of mostly empty pages.
