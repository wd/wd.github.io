+++
title = "Custom Netgear r6300v2 wireless router"
date = "2016-03-27T11:50:38+08:00"
tags = ["linux", "router", "gfw"]
description = ""
+++

接 [科学上网](/Across-the-Great-Wall-we-can-reach-every-corner-in-the-world)。买了群晖之后，一直通过群晖上面跑一个 haproxy 来做转发。不过心里总觉得有点不爽，毕竟一方面多转发了一次，另外群晖在不使用的时候，还会休眠，又或多或少担心影响休眠（经过测试应该是不影响的，但是..）。所以买了 r6300v2 之后，就琢磨通过路由器做这个事情。

路由器上面搞就有两个选择，一是从 iptables 入手，直接转发出去，另外一个是从软件层面做。

开始搞了几天的 iptables，发现原有系统 iptables 条目还是挺多的，加上路由器翻墙的功能也需要加一些条目，导致尝试了好几天之后总算能够转发过去链接了，但是数据包过不去，为了调试就开始打算在路由器安装 tcpdump。然后找到了 https://github.com/Entware/entware ，配置好之后可以使用 opkg 来安装包。包列表可以参考这里 http://pkg.entware.net/binaries/armv7/Packages.html ，这个路由器是 armv7 版本的 cpu。

安装 opkg 之前先得了解下，梅林固件分两部分存储，一部分是系统区，一部分是自定义区。系统区应该是你刷的固件所在的地方，是不能修改的，自定义区是可以存放一些自己定义的脚本的。每次系统启动的时候，你的一些自定义的东西都是存在自定义区加载的。自定义区就是 /jffs 分区。想要使用，得在 系统管理 -> 系统设置 里面，打开 JFFS 的配置，允许执行上面的脚本。

因为系统自带的 /jffs 分区只有 60M 左右，而我们装包的时候很容易就超过这个限制了，我现在已经用了 8xM 空间。所以最好还是用一个 u 盘来做这个事情。每次想要自动加载 u 盘，启动 u 盘里面的程序的话，还需要一些自定义的脚本来做这个事情。

先把 opkg 配置好，需要先准备好 /opt 目录。

```
mkdir -p /tmp/opt
mount -t ext4 -o rw,noatime /dev/sda1 /opt
```

上面的 /dev/sda1 是 u 盘，ext4 是文件系统类型，按照自己的修改一下。一般 u 盘插上去就会自动挂载，df 看一下就知道是哪个名字了。系统配置里面有个 dlna 的配置记得关掉，否则他会读 u 盘导致你不能 umount 之类，或者 kill 掉一个叫做 minidlna 的进程也可以。

然后参考 https://github.com/Entware/entware 操作就可以了，可以看到他会在 /opt 给你安装一陀东西。因为这个是 u 盘，所以东西重启也不会丢失。

然后参考[梅林的 wiki](https://github.com/RMerl/asuswrt-merlin/wiki/User-scripts)，它允许用户在 `/jffs/scripts` 自定义一些启动脚本，来支持我们自动挂载和启动 u 盘上面的程序。

post-mount 内容如下，前面几个注释的是调试用的。最后一个 if 里面内容是执行一些 opkg 安装的程序的启动脚本，这个后面说。
```
#!/bin/sh

#echo $(date) > /tmp/000service-start
#echo "$1" >> /tmp/000service-start
#ls /dev/sda* >> /tmp/000service-start

if [ -b /dev/sda1 ];then
        mkdir -p /tmp/opt
        mount -t ext4 -o rw,noatime /dev/sda1 /opt
fi

if [ -x /opt/bin/opkg ];then
        /opt/etc/init.d/rc.unslung start
fi
```

要记得 `sudo chmod +x post-mount`，然后可以重启路由器看看是不是启动之后就能看到 /opt 有了你上次安装的程序了。

上面一阶段搞定之后，就可以装一些软件了，比如我装了 vim, tcpdump，bind-dig, haproxy。opkg 的命令使用可以参考这里 https://wiki.openwrt.org/doc/techref/opkg 。

接着上面的话题，本来打算装好 tcpdump 来调试的，然后发现可以比较方便的启动 haproxy 之后，就打算用 haproxy 弄了，路由表太多，分析比较麻烦，还是走简单的吧。。

`/opt/etc/haproxy.cfg` 如下，把 IP 和 PORT 改成你自己的。

```
global
        ulimit-n  331071

defaults
        log global
        mode    tcp
        option  dontlognull
        timeout connect 1000
        timeout client 150000
        timeout server 150000

frontend ss-in
        bind *:本机PORT
        default_backend ss-out

backend ss-out
        server server1 IP:远端PORT maxconn 20480
```

`/opt/etc/init.d/S001haproxy.sh` 如下，`sudo chmod +x /etc/init.d/S001haproxy.sh`

```
#!/bin/sh

haproxy_bin=/opt/sbin/haproxy
haproxy_cfg=/opt/etc/haproxy.cfg
pid=/opt/var/run/haproxy.pid

action=$1

if [ -z "$action" ];then
        printf "Usage: $0 {start|stop|restart}\n" >&2
        exit 1
fi

case "$action" in
        start)
                $haproxy_bin -f $haproxy_cfg -p $pid -D
                ;;
        stop)
                kill $(cat $pid)
                ;;
        restart)
                kill $(cat $pid)
                $haproxy_bin -f $haproxy_cfg -p $pid -D
                ;;
esac
```

因为前面在 post-mount 最后一个 if 里面的语句，这样启动路由器就会自动启动 haproxy 了。

想使用这个端口转发，还需要在路由器配置界面里面增加一个到路由器 ip 的映射，然后还需要一个 `/jffs/scripts/firewall-start` 如下

```
#!/bin/sh

iptables -I INPUT -i ppp0 -p tcp --destination-port PORT -j ACCEPT
```

我使用的过程中还发现一个问题，pkg.entware.net 貌似被墙了。。虽然配置了翻墙但是不太明白为什么路由器上面时好时坏，而我局域网内的 mac 访问总是 ok 的，很奇怪。路由器上面不能访问有个办法是通过 mac 代理一下。

mac 上面启动一个 ngx，配置如下，使用 nginx -p ./ -c nginx.conf 启动。
```
events {
  worker_connections 1024;
}


http {
  server {
      listen 0.0.0.0:8000;
      location / {
           proxy_pass http://pkg.entware.net;
      }
  }
}
```

然后修改路由器上面 /opt/etc/opkg.conf `src/gz packages http://MAC_IP:8000/binaries/armv7`，然后就可以了。

写完自己看发现这不是一份操作指南，只能算是一些提示，如果有人照着做能不能成功可能还是得看自己。。。
