+++
title = "postgresql transaction isolation"
date = "2015-05-10T23:20:49+08:00"
tags = ["postgresql"]
description = ""
+++


翻译自 http://www.postgresql.org/docs/current/static/transaction-iso.html， 内容没翻译全，供参考。

## 并发控制

### 13.2 事务隔离级别

SQL 标准定义了四个事务隔离级别。最严格的就是串行化(Serializable)，根据标准定义，任何并发的串行化事务如果在相同的时间使用相同的顺序执行，那么需要有相同的执行结果。其他的三个隔离级别，都定义了在并发事务互相影响的情况下，在各隔离级别下不允许出现的一些现象。根据标准，这些现象都不允许出现在串行化这个级别。(这并不令人惊讶 -- 如果为了事务的结果一致只允许同时运行一个事务，那怎么可能会出现因为事务互相影响产生的现象)。

在各级别禁止的一些现象如下：

脏读(dirty read)

	一个事务读取到另一个并发的事务还没有提交的数据。

不可重复读(nonrepeatable read)

	一个事务重复读取之前读过的数据的时候，发现数据已经被其他事务修改（就是在第一次读取之后做的提交)。

幻读(phantom read)

	一个事务重新执行一个查找符合条件的数据的查询的时候，发现返回的数据因为这期间别的事务做了提交而发生了变化。

四个事务隔离级别和对应的行为在表 13-1 中进行了描述。

表 13-1 SQL 标准定义的事务隔离级别

| 事务隔离级别               | 脏读   | 不可重复读 | 幻读   |
|----------------------------+--------+------------+--------|
| 读未提交(read uncommitted) | 可能   | 可能       | 可能   |
| 读已提交(read committed)   | 不可能 | 可能       | 可能   |
| 可重复读(repeatable read)  | 不可能 | 不可能     | 可能   |
| 串行化(serializable)       | 不可能 | 不可能     | 不可能 |


（译者注：这个表格是个很大的迷惑，要注意他描述的只是标准定义的，而不是 PostgreSQL 里面的情况，在 PostgreSQL 中的实际情况和上面表格标记的不一致，下面的译文里面也多次会提到。）

在 PostgreSQl 中，你可以使用任意的四个隔离级别。但是，在内部其实只有三个，分别对应到读已提交、可重复读和串行化。当使用读未提交这个级别的时候，实际上和读已提交是一样的，而幻读在 PostgresSQL 的可重复读级别是不可能出现的，所以在 PostgreSQL 中实际的隔离级别可能比你选的更加严格一点。这个是 SQL 标准允许的：标准里面的四个隔离级别只定义了哪种现象不能出现，没有定义哪种现象一定会出现。PostgreSQL 只提供了三个隔离级别，是因为这是唯一比较合理的把标准定义的隔离级别映射到多版本并发控制架构上面的办法。在下面的章节里面会详细讲解各个隔离级别。

设置事务隔离级别的语句是 set transaction。

	重要提示：有些 PostgreSQL 的数据类型和函数在事务里面有特别的表现。特别的，对于序列(sequence)(以及定义为 serial 类型的列对应的序列)的修改会立刻对所有事务有效，并且在事务回滚的时候也不会被回滚。请参考 9.16 和 8.1.4。

#### 13.2.1 读已提交事务隔离级别

读已提交是 PostgreSQL 里面默认的事务隔离级别。当一个事务使用此级别的时候，一个 select 查询(不带 for update/share 字句)只可以查到当前查询开始前已经提交的数据，(在此查询执行的过程中)永远不会查到其他并发事务执行时的未提交数据和已提交的修改。事实上，一个 select 查询可以"看“到执行开始瞬间的数据库的一个快照。不过，select 查询可以”看“到当前事务里面已经完成更新的数据，即使他们还没有被提交。同时也要注意，如果有其他事务在一个事务的第一个 select 执行之后提交了修改，那么那个事务里面的前后成功的两个 select 查询也有可能得到不同的结果。

update, delete, select for update, 和 select for share 这些语句在查找目标数据的时候的时候，表现和 select 是一样的：都是只能查找到在语句执行开始的时候就已经提交的数据。然而，这些目标数据可能就已经被其他并发事务修改（或者删除、加锁(locked))了。在这种情况下，即将执行更新的事务将会等待第一个执行了更新的事务的提交或者回滚（如果他仍然在执行中）。如果第一个更新事务执行了回滚，那么它的执行结果会取消，后续的更新事务会处理所有之前查找到的数据。如果第一个更新事务执行了提交，那么后续的更新事务会忽略第一个事务删除的行，然后针对已经更新过的数据上面执行它自己的操作。语句里面的查询条件（where 语句）会重新被执行来查看已经更新的数据是否还满足条件。如果满足，那后续的更新事务会在已经更新过的数据上面执行他自己的操作。如果执行的是 select for update 和 select for share 语句，那会返回或者锁定更新后的数据给客户端。

基于以上规则，一个更新语句可能会得到一个“不稳定”的快照。它会“看”到其他并发事务对它将要更新的数据的修改，但是“看”不到其他并发事务对其他数据的修改。这个行为会导致读已提交事务隔离级别不适用于一些复杂的查询，只适用于简单的情况。例如，想象一下在事务里面更新银行账户余额：

``` SQL
BEGIN;
UPDATE accounts SET balance = balance + 100.00 WHERE acctnum = 12345;
UPDATE accounts SET balance = balance - 100.00 WHERE acctnum = 7534;
COMMIT;
```

如果有两个类似的事务要更新 12345 这个帐号的余额，我们显然是希望第二个更新事务是基于第一个的结果来更新。因为每个语句都是更新既定的数据，所以只能“看”到更新的数据不会造成不一致。

在读已提交事务隔离级别里面，复杂一点的情况可能会得到预期之外的结果。例如，想象一下一个 delete 语句操作的数据被其他语句从他的限制条件里面增加或者移除。例如，假设 website 是一个包含两行数据的表，其中 website.hits 字段分别等于 9 和 10。

``` SQL
BEGIN;
UPDATE website SET hits = hits + 1;
-- run from another session:  DELETE FROM website WHERE hits = 10;
COMMIT;
```

虽然在执行 update 前后，都有 website.hits = 10 的数据，但是那个 delete 语句将没有任何效果。这是因为未执行成功 update 前，9 这行数据是被 delete 忽略的，当 update 执行完毕，delete 得到锁之后，新的数据的值已经不是 10 而是 11 了，已经不再符合 delete 的条件了。

读已提交事务隔离级别在事务开始的时候会创建一个包含了在那个瞬间所有已提交的事务的数据的快照，同一个事务里面的后续语句会“看”到其他并发事务提交的数据。前面的问题的关键点是，单个语句是否可以得到一个持续一致的数据库。

读已提交事务隔离级别对于很多程序来说就已经足够了，使用起来快速简单。显然，它并不适用于所有情况。对于使用了复杂查询和更新的程序，或许需要对数据一致性要求比读已提交更加严格的事务隔离级别。

#### 13.2.2 可重复读事务隔离级别

可重复读事务隔离级别只能“看”到在事务开始前已经提交的数据，并且永远也“看”不到未提交的或者在事务执行期间被其他并发事务更新的数据。（当然，查询语句是可以“看”到在当前事务里面的已经执行的更新的，即使他们还没有被提交。）这么做比 SQL 标准里面针对这个隔离级别的要求严格，在表 13-1 里面表述的现象都不能发生。如前面所说，这么做标准是允许的，标准只描述了各隔离级别最低的要求。

这个隔离级别不同于读已提交隔离级别，在可重复读事务隔离级别里面一个查询可以“看”到事务开始的时候的一个快照，不是当前事务里面当前查询开始的时候的快照。因此，一个事务里面成功执行的 select 语句会得到相同的结果，也就是说，他们都”看“不到在事务开始之后其他事务提交的修改。

使用这个隔离级别的应用，应该在遇到序列化失败(serialization failures)的时候准备好重试。

update, delete, select for update, 和 select for share 这些语句在查找目标数据的时候的时候，表现和 select 是一样的：都是只能查找到在事务执行开始的时候就已经提交的数据。然而，这些目标数据可能就已经被其他并发事务修改（或者删除、加锁(locked))了。在这种情况下，可重复读事务将会等待第一个执行了更新的事务的提交或者回滚（如果他仍然在执行中）。如果第一个更新事务执行了回滚，那么它的执行结果会取消，后续的更新事务会处理所有之前查找到的数据。如果第一个更新事务执行了提交（真的对数据执行了更新或者删除，不是只是加了锁），那么可重复读事务会执行回滚，并且报错

```
ERROR:  could not serialize access due to concurrent update
```

因为可重复读事务在事务开始后不能对被其他事务做了修改的数据做修改或者锁定。

当应用程序得到这个错误信息的时候，应该立刻中止当前事务，重新从事务开始再次执行。再次执行的时候，这个事务就可以”看“到之前被其他事务提交的修改了，所以使用新版本数据作为新事务的起点的时候，就不会再有逻辑冲突了。

要注意只有有更新操作的事务才需要重试，只读的事务是永远不会有序列化冲突的。

读已提交事务隔离机制严格保证了每个事务都得到一个完整稳定的数据库快照。However, this view will not necessarily always be consistent with some serial (one at a time) execution of concurrent transactions of the same level. For example, even a read only transaction at this level may see a control record updated to show that a batch has been completed but not see one of the detail records which is logically part of the batch because it read an earlier revision of the control record. Attempts to enforce business rules by transactions running at this isolation level are not likely to work correctly without careful use of explicit locks to block conflicting transactions.

提示：在 PostgreSQL 9.1 以前，序列化事务隔离级别的情况和前面描述的信息是一样的。如果需要以前的序列化事务隔离级别，那可以使用现在的可重复读隔离级别。

#### 13.2.3 序列化隔离级别

序列化事务隔离级别是最严格的事务隔离级别。这个级别把所有已经提交的事务模为拟序列化执行，就像是事务执行完一个执行另一个，顺序的，而不是并发的。当然，类似于可重复读事务隔离级别，应用程序在序列化失败的情况下必须要准备好重试。事实上，这个级别和可重复读事务隔离级别是一模一样的，除了会监控 except that it monitors for conditions which could make execution of a concurrent set of serializable transactions behave in a manner inconsistent with all possible serial (one at a time) executions of those transactions. This monitoring does not introduce any blocking beyond that present in repeatable read, but there is some overhead to the monitoring, and detection of the conditions which could cause a serialization anomaly will trigger a serialization failure.

举个例子，比如有表 mytab，初始的时候如下：

```
 class | value
-------+-------
     1 |    10
     1 |    20
     2 |   100
     2 |   200
```

假设在序列化事务 A 里面执行：

``` SQL
SELECT SUM(value) FROM mytab WHERE class = 1;
```

然后把结果（30）作为 value 字段，class = 2 作为新行插入回去。同时，序列化事务 B 里面执行：

``` SQL
SELECT SUM(value) FROM mytab WHERE class = 2;
```

得到结果 300,并把结果和 class = 1 作为新行插入回去。然后两个事务都尝试提交。如果任意事务执行在可重复读级别，那么两个事务都可以提交; but since there is no serial order of execution consistent with the result, 使用序列化事务隔离级别的话，会允许其中一个事务提交，而回滚另一个事务，并且报如下错误信息：

```
ERROR:  could not serialize access due to read/write dependencies among transactions
```

这是因为如果 A 在 B 之前执行的话，B 的计算结果就会是 330 而不是 300,类似的，其他顺序会导致 A 得到不同的结果。

