+++
title = "Upgrade kernel to 4.9 for linode"
date = "2017-01-16T18:37:56+08:00"
tags = ["linode", "kernel", "bbr"]
description = ""
+++

bbr 那么牛逼，赶紧赶一个潮流。其实我之前用了 kcp，也是类似的东西，不过那个要求服务器端和客户端都需要跑 kcp 服务才可以。bbr 就不用了，只需要服务器配置好就可以了。

Linode 实际上已经提供了 4.9 的内核。打开 `Dashboard`，然后点击你使用的 profile 右侧的 edit，在出来的界面里面，Kernel 右侧的列表里面，有个 4.9 的选项，不过我测试这个内核并不能打开 bbr，不知道是怎么回事，有兴趣的可以试试看，要注意选对架构（就是 64 还是 32）。

所以还是需要自己装内核。debian 官方已经打包好了 kernel 4.9，访问 http://mirrors.kernel.org/debian/pool/main/l/linux/ ，然后找到适合自己的 linux-image-4.9，我的是 http://mirrors.kernel.org/debian/pool/main/l/linux/linux-image-4.9.0-1-amd64-unsigned_4.9.2-2_amd64.deb ，下载到 vps 上面。

然后执行 `sudo dkpg -i ./linux-image-4.9.0-1-amd64-unsigned_4.9.2-2_amd64.deb`，最后应该会提示一个错误，缺少依赖的包。这个时候执行 `sudo apt-get -f install`，会提示安装缺失的包。

然后，还需要安装 `grub`。看你的情况。就刚才 profile 编辑的页面里面，kernel 右侧的选项里面，你看看你的是 `grub2` 还是 `pv-grub`。

* `grub2`: 参考[这个](https://www.linode.com/docs/tools-reference/custom-kernels-distros/run-a-distribution-supplied-kernel-with-kvm)
```
$ sudo apt-get install grub2
$ sudo update-grub
```

* `pv-grub`: 参考[这个](https://www.linode.com/docs/tools-reference/custom-kernels-distros/run-a-distributionsupplied-kernel-with-pvgrub)
```
$ sudo apt-get install grub
$ sudo mkdir /boot/grub
$ sudo update-grub
```

然后在 profile 编辑页面里面，kernel 右侧选择对应的 grub 选项，重启 vps 就可以了。如果启动失败了，就在这个选项里面，选择之前的选项重启就可以恢复。
