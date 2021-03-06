+++
title = "use gearman to distribute you nagios check"
date = "2016-01-18T15:14:36+08:00"
tags = ["nagios", "gearman"]
description = ""
+++

# 安装

## gearman

需要 boost > 1.39, libevent-devel, libuuid-devel, gperf
需要 gcc >= 4.2

export CC=gcc44
export CC=g++44

## mod-gearman

libtool-ltdl-devel ncurses-devel
--with-gearman

# 配置

gearman 分为几个模块
* mod_gearman: 负责把 nagios 中的检查任务发给 gearmand job server
* gearmand: 负责接收任务，分配给 worker 执行。这个是个通用的队列管理服务。
* gearman_workder: 负责消费 gearmand 中的 job。

其中 `mod_gearman` 的代码里面包括了上面提到的 mod_gearman 和 gearman_workder。

所以规划好 gearmand 启动的机器，以及你的 worker 机器。其中要注意 worker 机器上面是会执行所有[1] nagios 监控

需要配置的文件有几个
* nagios.cfg 增加 broker
* mod-gearman/etc/mod_gearman/mod_gearman_neb.conf broker 的配置文件
* mod-gearman/etc/mod_gearman/mod_gearman_worker.conf workder 的配置文件

# 启动
* 先启动 gearmand 使用 mod-gearman/etc/init.d/gearmand 这个脚本。
* 启动 worker 使用 mod-gearman/etc/init.d/mod_gearman_worker 这个脚本。启动之后可以用 gearman_top 看到多了一些队列。
* 重启 nagios

确认 nagios.log 里面正常加载了 gearman，然后看 gearman_top 里面开始有一些 run 的 job 了。

# 注意事项

基本上使用 gearman 还算是对用户透明，需要配置的东西不多，默认配置就可以跑。

一般使用 gearman 的时候都是现有 nagios 遇到瓶颈了，这个时候扩展的时候需要注意下，第一步可以在 nagios 机器上面（或者弄一台新的机器）做 gearman 的 job server，然后在 nagios 的机器上面跑一个 worker，这样基本就是 0 配置都可以跑起来，不会有任何问题。

第一步完成之后就会需要增加 worker，这个时候就要注意了，新的 worker 机器上面，需要在相同的路径下面包括所有你用到的 nagios plugin（包括自己写的，也包括这些 plugin 依赖的其他内容，比如临时文件路径，配置文件等），否则分发过来的 job 会执行不成功。

这个时候有个办法，就是把原来机器的 nagios 相关目录通过 nfs 共享给其他机器（但是得注意二进制程序是兼容的）。

另外如果需要测试一下新的 worker，也可以通过配置只让 worker 执行某些 servicegroup 或者 hostgroup 的任务。要注意这个时候需要配置 service, eventhandler, host 都为 no，然后配置 servicegroups 或者 hostgroups。

# Footnotes

[1] 其实 worker 是可以被配置为只处理某些监控的，这个后面会讲。
