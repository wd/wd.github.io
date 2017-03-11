+++
title = "broadcom BCM wireless card on gentoo"
date = "2013-05-24T17:28:00+08:00"
comments = true
tags = ["linux"]
description = ""
+++

昨天又折腾了一下我的无线，是 dell 的本子，broadcom 的卡 BCM4313，准备写一下的时候，发现之前居然折腾过 [BCM4312](/bcm4312broadcom-stawpa_supplicantkernel2-6-33/)。。感觉真蛋疼。。

``` bash
$ lspci -vnn -d 14e4:
02:00.0 Network controller [0280]: Broadcom Corporation BCM4313 802.11b/g/n Wireless LAN Controller [14e4:4727] (rev 01)
        Subsystem: Dell Inspiron M5010 / XPS 8300 [1028:0010]
        Flags: fast devsel, IRQ 17
        Memory at e5300000 (64-bit, non-prefetchable) [size=16K]
        Capabilities: <access denied>
        Kernel modules: bcma
```

根据 [这里](http://wireless.kernel.org/en/users/Drivers/b43#bcm43xx.2C_b43legacy.2C_b43.2C_softmac.2C..._the_full_story) ， BCM 的网卡有三种可用驱动

 *  b43，kernel 自带，源自 broadcom linux 驱动的逆向工程
 *  brcmsmac, kernel 自带，似乎源自 broadcom 某个开源的驱动
 *  wl, broadcom 发布的 linux 驱动

另外，kernel 自带的 b43 和 brcmsmac 支持标准的 802.11 栈，可以通过 iw iwconfig 之类的工具来配置，获取状态。wl 就不行了。

如果想使用 b43 或者 brcmsmac，需要选择下面的 kernel 选项，要注意都选择成 module，因为还需要加载 firmware，如果编译进内核那需要把 firmware 也编译到内核才可以。
```
Networking support  --->  Wireless  ---> Generic IEEE 802.11 Networking Stack (mac80211)
Device Drivers  ---> Broadcom specific AMBA  --->  BCMA support
```
针对 b43 选择 `Device Drivers  ---> Network device support  --->  Wireless LAN  --->  Broadcom 43xx wireless support (mac80211 stack)`, 还需要安装 `sys-firmware/b43-firmware`。

针对 brcmsmac 选择 `Device Drivers  ---> Network device support  --->  Wireless LAN  --->  Broadcom IEEE802.11n PCIe SoftMAC WLAN driver`，还需要安装 `sys-kernel/linux-firmware`。

对于 wl，需要安装 `net-wireless/broadcom-sta`，安装的时候会自动检查必要的内核选项，按照提示选择好就可以了。主要是要注意去掉上面的 kernel 的选项，另外可能还需要一个 ipw2100 来提供某一个隐藏的 kernel 选项。此外还有个 PREEMPT_RCU 检查，需要选择下面的内核选项 `Processor type and features  --->  Preemption Model (Voluntary Kernel Preemption (Desktop))  --->  Voluntary Kernel Preemption (Desktop) `。

如此之后编译安装重启就可以了。

