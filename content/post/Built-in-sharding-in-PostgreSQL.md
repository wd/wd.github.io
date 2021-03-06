+++
title = "Built in sharding in PostgreSQL"
date = "2016-12-07T16:54:59+08:00"
tags = ["postgresql"]
description = ""
+++


PostgreSQL 内建 sharding 支持，粗略翻译自 https://wiki.postgresql.org/wiki/Built-in_Sharding

## Introduction

内建支持 sharding 最大的挑战是，如何用最小的代码修改实现。大部分社区的 sharding 修改支持都修改了很多 PostgreSQL 的代码，这也导致这些不能被 Postgres 社区那些不需要 sharding 的人接受。有了 FDW 之后，就有了在有限代码修改情况下实现内建 sharding 支持的可能。

基于 FDW 的这种 sharding 设计，是基于 NTT 开发的 Postgres-XC，大概已经有 10 年了。Postgres-XL 是基于这个设计的一种更加灵活的实现。

## Enhance Existing Features

* 已完成？提升 FDW 的基础设计和 postgres_fdw。特别的，好的性能要求合理的把一些操作推送到子节点(foreign shards)。在 Postgres 9.6 中，join, sort, update, delete 都可以推送到字节点了。聚合的 pushdown 将在 Postgres 10 中支持。FDW 表已经可以作为继承表出现。
* 提升分区支持有效提升 existence of shards。幸运的是，单节点的分区支持也需要重构才能提升性能和更多优化。例如，executor-based partition pruning.
* 给 FDW 请求增加并行支持。这样能允许节点并行执行，这个可能会通过多个异步的链接来实现。

## New Subsystems

还需要开发一些子系统：
* 允许表可以复制到所有节点，以允许更多的 join pushdown。这个可以通过 trigger 或者逻辑复制来完成。
* 实现一个子模块，以使用新的分区系统表来提交符合提交的查询的 FDW 查询。
* 实现一个子模块收集 FDW 查询的结果返回给用户。
* 实现全局事务管理器以便更加高效的允许子节点原子的提交事务。这个可能会通过 prepared 的事务来实现，还有某种在 crash 之后清理那些 preapared 的事务的事务管理器。例如 XA。
* 实现全局快照管理器，以允许子节点可以看到一致性的快照。（是不是 serialisable 事务模式会避免跨节点快照冲突？pg_export_snapshot() 或者 hot_standby_feedback 是不是会有帮助？) 多节点的备份的一致性也需要这个支持。
* 实现支持 create, manage, report on shards 这些用户 API。

## Use Cases

有四种可能的用户案例和不同的需求:
* 跨节点在只读节点上面执行只读聚合查询，例如数据仓库
  这种是最简单的场景，不需要全局事务管理，全局快照管理，并且因为聚合，所以子节点返回的数据量也是最小的。
* 跨节点在只读节点上面执行只读非聚合查询
  这种会给调度节点压力，需要收集和处理很多子节点返回的数据。这种也能看到 FDW 传输机制等级。
* 跨节点在可读写节点执行只读查询
  这个需要全局快照管理来保证子节点返回数据的一致性
* 跨节点执行读写查询
  这个需要全局快照管理器和全局事务管理器
