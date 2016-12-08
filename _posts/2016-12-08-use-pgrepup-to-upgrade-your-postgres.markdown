title: 使用 pgrepup 跨版本升级 pg
s: use pgrepup to upgrade your postgres
date: 2016-12-08 11:55:33
tags: postgres
---

[pgrepup](http://gasparin.net/2016/11/pgrepup-upgrade-postgresql-using-logical-replication/) 其实是一个支持 pg 跨版本复制的工具。而 pg 大版本升级需要停机是个比较郁闷的事情，如果能通过这个解决就实在太好了。下面测试了一下。

## 安装

需要安装 `pgrepup` 和 `pglogical`。

### 安装 pgrepup

pgrepup 官方说是支持 python >= 2.7 的版本，我自己测试的结果，python 3.5 里面执行有点问题，需要修改几个地方。但是在 python 2.7 里面，不需要做任何修改，所以建议使用 python 2.7。安装很简单，执行 `pip install pgprepup` 就可以了。

### 安装 pglogical

需要给你的 pg 安装这个扩展。高版本的和低版本的都需要安装。

安装也很简单，下载源码，执行 `PATH=/opt/pg96/bin:$PATH make USE_PGXS=1 install` 就好了。如果是给 pg95 装，那就把路径改成 pg95。

可以参考[这里](https://2ndquadrant.com/it/resources/pglogical/pglogical-installation-instructions/)。

## 配置

### 配置 db

先给几个 db 定义一下角色。db1 假设为 9.5 版本，db2 假设为 9.6 版本。

pgrepup 允许 db1, db2 和执行 pgrepup 所在的机器分别在不同的机器，也可以在相同的机器，看机器情况。

对于 db，最小配置的 postgres.conf 修改如下，我测试的时候两个 db 在一台机器上面，只需要修改 port 不一样就可以了。
```
listen_addresses = '*'          # what IP address(es) to listen on;
port = 5495
wal_level = logical # minimal, archive, hot_standby, or logical
max_wal_senders = 3             # max number of walsender processes
max_replication_slots = 3       # max number of replication slots
shared_preload_libraries = 'pglogical'          # (change requires restart)

## 下面几个参数不是必须设置的
logging_collector = on          # Enable capturing of stderr and csvlog
log_filename = 'postgresql-%Y-%m-%d.log'        # log file name pattern,
```

pg\_hba.conf 如下，修改其中的 client\_ip 和 db\_ip 为对应的真实 ip。
```
host all all client_ip/32 md5
host replication pgrepup_replication db_ip/32 md5
host all pgrepup_replication db_ip/32 md5
```

配置好之后，启动 db1 和 db2 看看是不是可以正常连接。

还需要建立用户。如果已经存在一个 super 的用户，那也可以直接用那个用户，没有的话，就建一个。db1 和 db2 都需要建立，可以是不同的用户。

#### hint

当然，如果我们在生产环境里面做这个事情，那肯定会是 db1 已经是一个存在的 db，只需要增加原来没有的配置就好了。db2 会是一个全新的 db，使用 initdb 初始化，之后配置上面的配置项（当然，如果是将来要给生产用，那应该是复制 db1 的配置文件过来，修改端口就可以了，其他都一样）。

### 配置 pgrepup

执行一下 `pgrepup config`
```
❯❯❯ pgrepup config
Pgrepup 0.3.7
Create a new pgrepup config
Configuration filename [~/.pgrepup] ./pgrepup.config
Security
Do you want to encrypt database credentials using a password? [Y/n] n
Folder where pgrepup store temporary dumps and pgpass file [/tmp] ./tmp
Source Database configuration
Ip address or Dns name: db_ip
Port: 5495
Connect Database: [template1]
Username: wd
Password:
Destination Database configuration
Ip address or Dns name: db_ip
Port: 5496
Connect Database: [template1]
Username: wd
Password:
Configuration saved to ./pgrepup.config.
You can now use the check command to verify setup of source and destination databases
```

之后会产生一个配置文件 pgrepup.config，有修改的话，可以打开再次编辑。

之后，可以执行一下 `pgrepup check` 来检查一下

```
❯❯❯ pgrepup -c pgrepup.config check
Pgrepup 0.3.7
Global checkings...
 >  Folder ./tmp exists and is writable ..........................................OK
Checking Source...
 >  Connection PostgreSQL connection to db_ip:5495 with user wd OK
 >  pglogical installation .......................................................KO

    Hint: Install docs at https://2ndquadrant.com/it/resources/pglogical/pglogical-installation-instructions/

 >  Needed wal_level setting .....................................................OK
 >  Needed max_worker_processes setting ..........................................OK
 >  Needed max_replication_slots setting .........................................OK
 >  Needed max_wal_senders setting ...............................................OK
 >  pg_hba.conf settings .........................................................KO
    Hint: Add the following lines to /home/wd/data95/pg_hba.conf:
        host replication pgrepup_replication db_ip/32 md5
        host all pgrepup_replication db_ip/32 md5
    After adding the lines, remember to reload postgreSQL
 >  Local pg_dumpall version .....................................................OK
 >  Source cluster tables without primary keys
 >      template1 ................................................................OK
 >      testdb
 >          public.t1 ............................................................OK
 >      postgres .................................................................OK
Checking Destination...
 >  Connection PostgreSQL connection to db_ip:5496 with user wd OK
 >  pglogical installation .......................................................KO

    Hint: Install docs at https://2ndquadrant.com/it/resources/pglogical/pglogical-installation-instructions/

 >  Needed wal_level setting .....................................................KO
    Hint: Set wal_level to logical
 >  Needed max_worker_processes setting ..........................................OK
 >  Needed max_replication_slots setting .........................................KO
    Hint: Increase max_replication_slots to 3
 >  Needed max_wal_senders setting ...............................................OK
 >  pg_hba.conf settings .........................................................KO
    Hint: Add the following lines to /home/wd/data96/pg_hba.conf:
        host replication pgrepup_replication db_ip/32 md5
        host all pgrepup_replication db_ip/32 md5
    After adding the lines, remember to reload postgreSQL
 >  Local pg_dumpall version .....................................................OK
```
上面是我第一次执行 check 的结果，可以看到很多红色的 `KO`，有些下面还有 hint 提示告诉你怎么修复，针对红色的信息进行修复就好了。

```
❯❯❯ pgrepup -c pgrepup.config check
Pgrepup 0.3.7
Global checkings...
 >  Folder ./tmp exists and is writable ..........................................OK
Checking Source...
 >  Connection PostgreSQL connection to db_ip:5495 with user wd ...OK
 >  pglogical installation .......................................................OK
 >  Needed wal_level setting .....................................................OK
 >  Needed max_worker_processes setting ..........................................OK
 >  Needed max_replication_slots setting .........................................OK
 >  Needed max_wal_senders setting ...............................................OK
 >  pg_hba.conf settings .........................................................OK
 >  Local pg_dumpall version .....................................................OK
 >  Source cluster tables without primary keys
 >      template1 ................................................................OK
 >      testdb
 >          public.t1 ............................................................OK
 >      postgres .................................................................OK
Checking Destination...
 >  Connection PostgreSQL connection to db_ip:5496 with user wd ...OK
 >  pglogical installation .......................................................OK
 >  Needed wal_level setting .....................................................OK
 >  Needed max_worker_processes setting ..........................................OK
 >  Needed max_replication_slots setting .........................................OK
 >  Needed max_wal_senders setting ...............................................OK
 >  pg_hba.conf settings .........................................................OK
 >  Local pg_dumpall version .....................................................OK
```

上面是我修复之后执行的结果。其中会提示会被同步的 db（上面是 template1, testdb, postgres）。之后执行 setup

```
❯❯❯ pgrepup -c pgrepup.config setup
Pgrepup 0.3.7
Check if there are active subscriptions in Destination nodes .....................OK
Global tasks
 >  Remove nodes from Destination cluster
 >      postgres .................................................................OK
 >      template1 ................................................................OK
 >      testdb ...................................................................OK
 >  Create temp pgpass file ......................................................OK
 >  Drop pg_logical extension in all databases of Source cluster
 >      template1 ................................................................OK
 >      postgres .................................................................OK
 >      testdb ...................................................................OK
 >  Drop pg_logical extension in all databases of Destination cluster
 >      postgres .................................................................OK
 >      template1 ................................................................OK
 >      testdb ...................................................................OK
Setup Source
 >  Create user for replication ..................................................OK
 >  Dump globals and schema of all databases .....................................OK
 >  Setup pglogical replication sets on Source node name
 >      template1 ................................................................OK
 >      postgres .................................................................OK
 >      testdb ...................................................................OK
Setup Destination
 >  Create and import source globals and schema ..................................OK
 >  Setup pglogical Destination node name
 >      postgres .................................................................OK
 >      testdb ...................................................................OK
 >      template1 ................................................................OK
Cleaning up
 >  Remove temporary pgpass file .................................................OK
 >  Remove other temporary files .................................................OK
```

然后执行 start

```
❯❯❯ pgrepup -c pgrepup.config start
Pgrepup 0.3.7
Start replication and upgrade
 >  postgres .................................................................OK
 >  template1 ................................................................OK
 >  testdb ...................................................................OK
```

可以通过 status 看同步状态

```
❯❯❯ pgrepup -c pgrepup.config status
Pgrepup 0.3.7
Configuration
 >  Source database cluster ......................................................OK
 >  Destination database cluster .................................................OK
Pglogical setup
 >  Source database cluster
 >      template1 ................................................................OK
 >      postgres .................................................................OK
 >      testdb ...................................................................OK
 >  Destination database cluster
 >      postgres .................................................................OK
 >      testdb ...................................................................OK
 >      template1 ................................................................OK
Replication status
 >  Database postgres
 >      Replication status ..............................................replicating
 >  Database testdb
 >      Replication status ..............................................replicating
 >  Database template1
 >      Replication status ..............................................replicating
 >  Xlog difference (bytes) ...................................................57816
```

可以看到三个 db 都在同步。这个时候在 db1 上面插入数据，能在 db2 上面看到会同步过去。

状态有三种情况
* initializing: pglogical 正在 copy 数据
* replication: 同步状态
* down: 同步断开了，需要检查日志修复

## 需要注意的问题

### db 里面的表都需要有主键

如果存在没有主键的表，执行 check 的时候会看到下面的信息

```
 >  Source cluster tables without primary keys
 >      template1 ................................................................OK
 >      testdb
 >          public.t2 ............................................................KO
    Hint: Add a primary key or unique index or use the pgrepup fix command
 >          public.t1 ............................................................OK
 >      postgres .................................................................OK
```

如果不解决就执行 setup，会提示下面的信息

```
Setup Source ........................................Skipped, configuration problems
Setup Destination
 >  Create and import source globals and schema .............................Skipped
 >  Setup pglogical Destination node name
 >      postgres .................................................................OK
 >      template1 ................................................................OK
 >      testdb ...................................................................OK
```

可以自己创建一个主键重新 check，也可以执行 fix 来修复，然后再次执行 setup。

```
 ❯❯❯ pgrepup -c pgrepup.config fix
Pgrepup 0.3.7
Find Source cluster's databases with tables without primary key/unique index...
 >  template1 ....................................................................OK
 >  postgres .....................................................................OK
 >  testdb
 >      Found public.t2 without primary key ................Added __pgrepup_id field
```

通过 fix 加的主键，在 uninstall 的时候会被删除。

 
### Replication status .. down

有时候会遇到有的 db 的状态是好的，有的 db 是 down 的情况

```
Replication status
 >  Database postgres
 >      Replication status ..............................................replicating
 >  Database testdb
 >      Replication status .....................................................down
 >  Database template1
 >      Replication status ..............................................replicating
 >  Xlog difference (bytes) ..................................................614096
```

在同步状态下面，如果给某个 db 加一个没有主键的表，就会导致同步断掉。修复方法是先 stop，然后执行 check，按照提示修复，然后执行 setup，然后 start 就可以了。





### 官方列出来的几个问题

* DDL 命令。不会同步 DDL 命令，可以在 db1 试试看 `pglogical.replicate_ddl_command`。
* seq 序列。执行 stop 命令的时候，会在目标 db 的 seq 上面加 1000。
* 有大量的 db。执行 start 命令之后，pglogical 会每个 db 启动一个 worker 来同步数据，要是 db 比较多会导致比较高的负载。

### pgrepup uninstall

uninstall 会清理 pgrepup 创建的一些信息，比如安装的 pglogical 扩展，创建用来同步的用户，和通过 fix 命令添加的 seq。

```
❯❯❯ pgrepup -c pgrepup.config uninstall
Pgrepup 0.3.7
Check active subscriptions in Destination nodes
 >  template1 ...............................................................Stopped
 >  testdb ..................................................................Stopped
 >  postgres ................................................................Stopped
Uninstall operations
 >  Remove nodes from Destination cluster
 >      postgres .................................................................OK
 >      testdb ...................................................................OK
 >      template1 ................................................................OK
 >  Drop pg_logical extension in all databases
 >      Source
 >          template1 ............................................................OK
 >          postgres .............................................................OK
 >          testdb ...............................................................OK
 >      Destination
 >          postgres .............................................................OK
 >          testdb ...............................................................OK
 >          template1 ............................................................OK
 >  Drop user for replication ....................................................OK
 >  Drop unique fields added by fix command
 >          template1
 >          postgres
 >          testdb
 >              public.t1 ........................................................OK
 >              public.t2 ........................................................OK
```

## 升级

如果前面配置好了同步状态，那剩下的事情就简单了。
* 停止应用链接 db1
* 确保 db1 已经没有任何链接
* 使用 `pgrepup stop` 停止 replication
* 修改应用链接到 db2
* 启动应用
* 剩下的就是处理掉停止的 db1

## 参考文档

http://qiita.com/yteraoka/items/e82e4d28f6a23915d190
