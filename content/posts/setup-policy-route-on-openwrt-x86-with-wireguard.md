---
title: "Setup Policy Route on Openwrt X86 With Wireguard"
date: 2021-11-06T15:07:32+08:00
tags: [""]
toc: true
---

# 刷系统

选择 image，我用的是 x86_64 的硬件。如果你不确定，可以选择 generic 的试试看，如果你能用 64 的，启动的时候提示你用 64 位的性能更好。

然后需要选择不同的包，主要是在下面两个里面选。
- squashfs-combined：类似传统路由器，可以任意重置路由器。但是磁盘大小也是固定大小。
- ext4-combined：磁盘可以 resize，如果你有超过 50G 的磁盘，都想要在路由器里面用，那就选这个。否则上面那个更好，毕竟有问题的时候重置很方便。这个恐怕只能重新刷系统了，麻烦多了。

准备两个 u 盘。如果你能有一个 u 盘可以启动加存放那个 img 那就更好了。
- 一个刷 debian live cd，启动的时候选择 live
- 一个里面放 openwrt 的 img `openwrt-21.02.0-x86-64-generic-ext4-combined.img`.

连接显示器，键盘。

先使用 livecd 启动之后，先确认下盘符。一般 /dev/sda 是内置的磁盘，/dev/sdb 是 livecd。确认后插入另外一个 u 盘，这个的盘符应该是 /dev/sdc。

```
mount /dev/sdc1 /mnt
cd /mnt
dd if=openwrt-21.02.0-x86-64-generic-ext4-combined.img of=/dev/sda
```
使用 cfdisk resize 下 /dev/sda2 并写到分区表。然后使用 `resize2fs /dev/sda2` 命令应用到文件系统。这个时候就可以使用路由器自带的 openwrt 启动了。

# 初始化
system -> system
- hostname
- timezone

system -> administration
- set password
- ssh access:
	- interface: lan
	- uncheck all the boxes
- ssh-keys
	- add your pub keys

`ssh root@192.168.1.1` 测试连接。

# 调整网络配置

调整的主要原因是
- 192.168.x.x 容易和某些 vpn 什么的冲突
- 把 eth0 改成 wan 口，其他都是 lan 口，比较符合直观的感受。

调整内容
- network
	- interfaces -> lan
		- ip address: 10.10.10.1
	- interfaces -> wan 和 wan6
		- device: eth0
	- devices -> br-lan
		- 把 eth0 之外都选上
这个操作之后，需要把线改接第二个口了。我遇到情况是 apply 之后部分修改没生效，别慌，把接口接回去应该还能继续配置。

# 使用 dnsmasq-full 替换 dnsmasq

这一步需要通过 ssh 操作。这一步放最前面是为了避免丢失配置，因为为了省事（解决配置冲突）需要删除 `/etc/config/dhcp`。

```
opkg update
opkg remove dnsmasq # 这一步可能会导致 dns 丢失，如果出现问题可以去 /etc/resolve.conf 里面重新配置下 dns
rm /etc/config/dhcp
opkg install dnsmasq-full
```

# 网络拓扑

openwrt -> wifi router -> pc/mac/iphone
10.10.10.1/24 -> 10.10.10.2/10.10.8.1/24 -> 10.10.8.x

这样的结构下，如果 openwrt 出问题，可以随时把外网接 wifi router 上面继续用，其他设备都不用动。等稳定之后，可以把 wifi router 改成桥接模式。

# 配置 wireguard
参考文档：https://openwrt.org/docs/guide-user/services/vpn/wireguard/server

## 规划下 wireguard 各个节点的 ip

这里需要提前规划下 wireguard 网络，我的目的是通过远端的 vps 上网，所以我的设置如下
- network: 10.10.20.1/24
- vps: 10.10.20.1
- openwrt: 10.10.20.11
- 其他设备: 10.10.20.21(mac),22(iphone)

## 安装配置 wireguard

- system -> software
	- update lists
	- install: wireguard-tools(必须) luci-proto-wireguard(通过配置 luci 配置 wireguard 必须) luci-app-wireguard(显示一些连接信息，不是必须)
	
这个时候可能需要重启下路由器才能继续，否则可能在菜单里面看不到 wireguard 这个选项

- network -> interfaces
	- Add new interface
		- name: wg0
		- protocal: wireguard vpn
		- create interface
			- private key: 可以点那个 generate key
			- listen port: 54321
			- ip address: 10.10.20.11
		- save
	- save and apply

这个时候执行 wg 命令应该可以看到 wg 设备的情况了。在 status -> wireguard 也可以看到。如果想要在这里支持 qr/code ，还需要安装一些 qrcode 相关的包。

## 配置 firewall

单独为 wg 创建一个 zone。允许通过 wg 访问 wan 和 lan。
- network -> firewall -> zones
	- add
		- name: wireguard
		- forward: accept
		- mss clamping
		- masquerading
		- covered networks: wg0
		- allow forward to dest zone: lan, wan, wan6，也可以设置只允许访问 wan。
		- *allow forward from source zone: lan*(这个好像是需要的)
		- save
	- save and apply

允许通过 wan 访问 54321
- network -> firewall -> traffic rule
	- add
		- name: Allow-wireguard-from-wan
		- protocol: udp
		- dest zone: input
		- dest port: 54321
		- save
	- save and apply

## 配置 wireguard peers

- network -> interfaces -> wg0 -> edit -> peers
	- add peer(客户端 peer)
		- description: Mac
		- pub key: 
		- allowed ips: 10.10.20.21/32
	- add peer(vps server)
		- description: vps
		- endpoint host: `vps ip`
		- endpoint port: `vps port`
		- allowed ips: 0.0.0.0/0
	- save
	- save and apply
	- restart interface

这个时候执行 wg 命令或者去 status -> wireguard 应该能看到更多信息了。比较关键的是确认下 vps 那个有没有连接成功，看 `latest handshake` 是什么时候。
```
peer: <pub_key>
  endpoint: <ip:port>
  allowed ips: 0.0.0.0/0
  latest handshake: 45 seconds ago
  transfer: 92 B received, 212 B sent
  persistent keepalive: every 25 seconds
```

也可以测试下是不是可以通过电脑或者手机连接这个 openwrt 上面的 wireguard。这个时候应该只能 handshake 成功，但是不能通过这个连接访问任何网站，因为还没有配置相关的路由。DNS 也不通。

# 配置路由

配置针对 10.10.20.0/24 网段的路由，配置之后就可以通过 wg 访问路由器的ip 10.10.10.1 了。
```
route add -net 10.10.20.0 netmask 255.255.255.0 dev wg0
```

如果你还想通过 wg 访问内网的设备(10.10.8.x)，还需要配置一条路由

network -> dhcp and dns -> static leases
- 找到 wifi router 的设备，给它设置为固定 ip

network -> static routes -> add
- interface: lan
- target: 10.10.8.0
- netmask: 255.255.255.0
- gateway: 10.10.10.2(这个是 wifi router 的固定 ip)

注意几点
- 需要关闭 wifi 的防火墙，因为路由器一般默认不允许从 wan 连接。
- wireguard 客户端的路由配置里面，增加 10.10.8.1/24，默认是没有的。

# 增加 route table

编辑 `/etc/iproute2/rt_tables`，增加一行
```
200 gfw
```

# 配置 dnsmasq 和 ipset
## 配置 ipset

安装 ipset

创建 `/etc/gfw.ip.ipset` 文件。里面存放需要通过 wg 访问的 ip。

```
8.8.8.8
1.1.1.1
```

创建 `/etc/gfw.net.ipset` 文件。里面存放需要通过 wg 访问的 cidr

```
# telegram
67.198.55.0/24
91.108.4.0/22
91.108.8.0/22
91.108.12.0/22
91.108.16.0/22
91.108.56.0/22
109.239.140.0/24
149.154.160.0/20
149.154.164.0/22
149.154.168.0/22
149.154.172.0/22
205.172.60.0/22
```

修改 `/etc/config/firewall` 文件。增加下面的内容
```
config ipset
    option name 'gfw'
    option match 'ip'
    option storage 'hash'
    option enabled '1'
    option loadfile '/etc/gfw.ip.ipset'
	
config ipset
    option name 'gfwnet'
    option match 'net'
    option storage 'hash'
    option enabled '1'
    option loadfile '/etc/gfw.net.ipset'
```

重启 firewall `/etc/init.d/firewall restart`. 执行 `ipset list` 查看结果
```
Name: gfwip
Type: hash:ip
Revision: 4
Header: family inet hashsize 1024 maxelem 65536
Size in memory: 200
References: 0
Number of entries: 0
Members:
1.1.1.1
8.8.8.8

Name: gfwnet
Type: hash:net
Revision: 6
Header: family inet hashsize 1024 maxelem 65536
Size in memory: 1216
References: 0
Number of entries: 12
Members:
149.154.172.0/22
109.239.140.0/24
91.108.8.0/22
67.198.55.0/24
149.154.168.0/22
149.154.160.0/20
91.108.12.0/22
91.108.16.0/22
149.154.164.0/22
91.108.56.0/22
91.108.4.0/22
205.172.60.0/22
```

**日后这两个文件 `/etc/gfw.net.ipset` 和 `/etc/gfw.ip.ipset` 就是管理静态的需要走 wg 的 ip 的文件。**

## 配置 dnsmasq
network -> dhcp and dns
- Listen interfaces: lan, wg

这个配置之后应该可以通过 wg 访问 openwrt 的 dns 了。

创建 `/etc/dnsmasq.d/gfw.conf` 文件，可以根据需要自己写，也可以使用别人写好的。格式如下
```
server=/twitter.com/8.8.8.8
ipset=/twitter.com/gfwip
```

也可以使用我整理好的 https://github.com/wd/gfwlist-ipset/blob/main/gfwlist-ipset.conf

修改 `/etc/config/dhcp` 文件，增加一行
```
config dnsmasq
	...
	option confdir '/etc/dnsmasq.d'
```

重启 dnsmasq, `/etc/init.d/dnsmasq restart`. 测试下
```
# dig twitter.com

; <<>> DiG 9.17.13 <<>> twitter.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 13344
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;twitter.com.                   IN      A

;; ANSWER SECTION:
twitter.com.            1227    IN      A       104.244.42.193
twitter.com.            1227    IN      A       104.244.42.1

;; Query time: 0 msec
;; SERVER: 127.0.0.1#53(127.0.0.1) (UDP)
;; WHEN: Sun Oct 24 22:38:47 CST 2021
;; MSG SIZE  rcvd: 72

# ipset list gfwip
Name: gfwip
Type: hash:ip
Revision: 4
Header: family inet hashsize 1024 maxelem 65536
Size in memory: 392
References: 0
Number of entries: 4
Members:
8.8.8.8
104.244.42.193
1.1.1.1
104.244.42.1
```

能看到 twitter ip 已经加入到了 ipset 里面。（这个测试里面不一定能返回正确的 twitter 的 ip，只是测试 dnsmasq + ipset 是正常工作的）。

**以后需要翻墙的域名就在这个 `/etc/dnsmasq.d/gfw.conf` 文件里面维护。也可以在这个目录放多个文件。**

## 配置匹配 ipset 的包走 wg

network -> firewall -> custom rules
```
iptables -t mangle -N fwmark
iptables -t mangle -A PREROUTING -j fwmark
iptables -t mangle -A OUTPUT -j fwmark

iptables -t mangle -A fwmark -m set --match-set gfwip dst -j MARK --set-mark 1
iptables -t mangle -A fwmark -m set --match-set gfwnet dst -j MARK --set-mark 1
```

路由规则
```
# 有 0x1 标记的，都走 gfw 这个 table
ip rule add fwmark 0x1 table gfw

# gfw 这个 table 默认都从 10.10.20.1 出去
ip route add default via 10.10.20.1 dev wg0 table gfw

```

## 配置 hotplug

上面的路由规则目前都是通过手动配置的，重启设备就没有了。需要配置一个自动添加的脚本。

创建一个文件 `/etc/hotplug.d/iface/50-wg`
```sh
#!/bin/sh

if [ "ifup" = "$ACTION" ] && [ "$INTERFACE" = "wg0" ]; then
        ip route add 10.10.20.0/24 dev wg0
        ip rule|grep -q 'fwmark 0x1 lookup gfw' || ip rule add fwmark 0x1 table gfw
        ip route add default via 10.10.20.1 dev wg0 table gfw
fi
```


# 排查错误

在全部配置好之后，最好重启下 openwrt，确保重启后依然是可以上网的。如果有问题，可以参考下面的步骤。

确保 ipset ok，应该有两个set `gfwip` 和 `gfwnet`。查询一个被屏蔽的 dns 之后能在 ipset 列表里面看到。
```
# ipset list
```

确保路由规则都在
```
# ip route show table gfw
default via 10.10.20.1 dev wg0

# ip rule|grep fwmark
32765:  from all fwmark 0x1 lookup gfw

# ip route |grep wg
10.10.20.0/24 dev wg0 scope link
```

iptables 规则 ok
```
# iptables -t mangle -nvL PREROUTING
Chain PREROUTING (policy ACCEPT 26721 packets, 5880K bytes)
 pkts bytes target     prot opt in     out     source               destination
  27M   31G fwmark     all  --  *      *       0.0.0.0/0            0.0.0.0/0
 
# iptables -t mangle -nvL OUTPUT
Chain OUTPUT (policy ACCEPT 6295 packets, 2828K bytes)
 pkts bytes target     prot opt in     out     source               destination
 307K   86M fwmark     all  --  *      *       0.0.0.0/0            0.0.0.0/0

# iptables -t mangle -nvL fwmark
Chain fwmark (2 references)
 pkts bytes target     prot opt in     out     source               destination
 188K   29M MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            match-set gfwip dst MARK set 0x1
 1417  157K MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            match-set gfwnet dst MARK set 0x1
 ```

启用 log
system -> logging
- write system log to file: /tmp/system.log

通过看 FORWARD 和 POSTROUTING 的日志来判断可能是哪里有问题。
```
DEST=8.8.8.8
iptables -t filter -A FORWARD -d $DEST -j LOG --log-prefix 'FWD:'
iptables -t mangle -A POSTROUTING -d $DEST -j LOG --log-prefix 'POST:'

DEST=10.10.8.1
iptables -t filter -D FORWARD -d $DEST -j LOG --log-prefix 'FWD:'
iptables -t mangle -D POSTROUTING -d $DEST -j LOG --log-prefix 'POST:'

```

如果只有 FORWARD 没有 POSTROUTING，那就是包被 drop 了。同时也观察包是否有正确的 src dst 和 mark。

# 其他

## iptv

network -> interfaces -> add
- name: iptv
- protocal: dhcp
- device: eth0
- advanced settings 
	- use default geteway: 去掉选择

安装 luci-app-udpxy

services -> udpxy
- enabled 选上
- status 选上
- port 4022
- source ip/interface: eth0
- 其他都留空
- save and apply

访问 http://10.10.10.1:4022/status 能看到 `Multicast address` 是 192.168.1.x 这样的 ip。可以找一个地址测试下是不是可以用吧。

## ddns

安装 ddns-scripts-cloudflare ca-certificates

services -> ddns -> add
- hostname: x.abc.com
- ddns service provider: cloudflare.com-v4
- domain: x@abc.com
- username: Bearer
- password: token from cloudflare
- path to ca certs: /etc/ssl/certs
- save

点击那个 reload 可以重复执行。点击 edit 可以看 log，如果遇到 ssl 错误，可能需要安装 `libwolfssl4.8.1.66253b90`，openwrt 默认使用 [wolfssl](https://openwrt.org/releases/21.02/notes-21.02.0-rc1#tls_and_https_support_included_by_default) 。

## 穷人的防屏蔽措施

wireguard 连不上也很稀松平常，一方面 UDP 被 Qos，另外一方面就是 GFW 作怪。我在 twitter 上面无意中看到一个措施感觉还有点用。思路就是在服务器端开 N 个 wireguard 端口，客户端连接有问题的时候就换一个。

当然实际上在服务器端也不用真的开 N 个，只需要用 iptables 转发到真实的端口就行。就是类似下面这句，把其中的几个端口改改就行。

```
iptables -t nat -A PREROUTING -p udp --destination-port 20011:23344 -j REDIRECT --to-ports 1234
```

然后在 openwrt 里面，增加一个 crontab 定期检查网络是不是通的就行。这里面几个端口可能需要改改，以及 wg 设备的名字。 crontab 项目类似这个 `* * * * * /etc/wg/change-wg-port.sh`.

```bash
LOG=/tmp/check_gfw.log


log() {
    echo "$(date +%F_%T) $1" >> $LOG
}

check_gfw() {
    code=$(curl -s -o /dev/null -w "%{http_code}" google.com)
    if [ "$code" = "301" ]; then
        log "google.com is ok"
    else
        log "google.com is not ok $code, switch port"
        switch_port
    fi
}

switch_port() {
    current_port=$(uci get network.@wireguard_wg0[2].endpoint_port)
    new_port=$(expr $current_port + 1)
    if [ "$new_port" = "23344" ];then
      new_port=20011
    fi
    log "new port is $new_port"
    uci set network.@wireguard_wg0[2].endpoint_port=$new_port
    uci commit network
    ifup wg0
}

check_gfw
```

这个是我的一些检查日志，8.5 断了九分钟，8.7 断了三分钟。这个因为是 1 分钟检查一次，所以可能会有点慢，但是，总归比什么都不做强。。
```
2022-08-02_12:53:05 google.com is not ok 000, switch port
2022-08-05_22:24:05 google.com is not ok 000, switch port
2022-08-05_22:25:05 google.com is not ok 000, switch port
2022-08-05_22:26:05 google.com is not ok 000, switch port
2022-08-05_22:27:05 google.com is not ok 000, switch port
2022-08-05_22:28:05 google.com is not ok 000, switch port
2022-08-05_22:29:05 google.com is not ok 000, switch port
2022-08-05_22:30:05 google.com is not ok 000, switch port
2022-08-05_22:31:05 google.com is not ok 000, switch port
2022-08-05_22:32:05 google.com is not ok 000, switch port
2022-08-07_02:11:15 google.com is not ok 000, switch port
2022-08-07_02:12:05 google.com is not ok 000, switch port
2022-08-07_02:13:05 google.com is not ok 000, switch port
2022-08-07_02:14:05 google.com is not ok 000, switch port
```

## 其他
- 通过配置 port-foward -> router 开放 router 下面客户端的端口。例如 NAS bt 下载用的 p2p 端口。注意还需要在 router 里面也做这个映射。当然也可以直接把 nas 接到 openwrt。
- 如果在路由配置好之前发生了针对被污染的域名的 dns 查询，那很可能会缓存被污染的结果，目前没想到什么好办法。不过好在一般等 dns 过期之后就正常了。

## TODO
- ipv6 支持：因为这个方案目前不支持 ipv6，所以如果有 app 优先使用 ipv6 查询的话，那么返回的 ipv6 地址是不会走 wg 的，这个时候就会出现不能用。解决方法就是关闭这个设备的 ipv6，或者直接关闭 openwrt 的 ipv6 支持。
