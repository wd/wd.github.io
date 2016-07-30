title: setup proxy for emacs
date: 2016-02-27 21:55:20
tags:
  - emacs
  - osx
---
我在 mac 上面使用 emacs 都是使用 daemon + emacsclient 模式。使用 `paradox` 包管理(其实就是比 `list-package` 稍微多了一点功能')，但是因为那些包什么的信息都在国外的网站，还有 github 什么的，导致速度巨慢甚至连不上，关键 emacs 单线程还得卡着别的操作，所以挺讨厌的(其实 paradox 提供了异步更新的方式，不会阻塞现在进程，但是有时候会不知道进度...)。

思路就是使用 `proxychains`。

新建一个 `/Library/LaunchAgents/gnu.emacs.daemon.plist` 文件

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
 <plist version="1.0">
  <dict>
    <key>Label</key>
    <string>gnu.emacs.daemon</string>
    <key>ProgramArguments</key>
    <array>
      <string>/usr/local/bin/proxychains4</string>
      <string>-f</string>
      <string>/Users/wd/.proxychains/proxychains.conf</string>
      <string>/usr/local/opt/emacs-mac/bin/emacs</string>
      <string>--daemon</string>
    </array>
   <key>RunAtLoad</key>
   <true/>
   <key>ServiceDescription</key>
   <string>Gnu Emacs Daemon</string>
   <key>UserName</key>
   <string>wd</string>
  </dict>
</plist>
```

其中 `/Users/wd/.proxychains/proxychains.conf` 文件的内容如下

```
strict_chain
proxy_dns
remote_dns_subnet 224
tcp_read_time_out 15000
tcp_connect_time_out 8000
localnet 127.0.0.0/255.0.0.0
localnet 10.0.0.0/255.0.0.0
localnet 172.16.0.0/255.240.0.0
localnet 192.168.0.0/255.255.0.0
quiet_mode

[ProxyList]
#socks5 127.0.0.1 1080
http 127.0.0.1 6152
```
