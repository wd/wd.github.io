+++
title = "如何不花钱建立一个支持 https 的 blog"
s = "how to create a blog with https for free"
date = "2016-04-10T10:18:28+08:00"
tags = ["blog"]
description = ""
+++

早年的时候要搞 blog 还得弄一个空间，现在，免费的东西越来越多了，感觉共产主义的实现还要靠资本家啊，不过羊毛出在羊身上。。。

要想弄一个免费的 blog，首先你的 blog 内容最好是纯静态网页，如果是类似 php 什么的，那就难找了。使用 jeklly, hexo 这些都可以把 markdown 文件渲染成 html。

然后注册一个 github 或者 gitcafe 等等支持 pages 服务的空间，搞定之后就能得到一个类似于 http://wd.github.io 这样的地址。

然后你注册一个域名（发现标题没起好，这个还是要收费的。。），然后注册 cloudflare，把你的域名的 dns 使用 cloudflare 的，然后在 cloudflare 配置一个 cname 到 wd.github.io。然后建立一个 page rule，强制你的域名使用 ssl。

ok 拉，整个过程就是域名花钱了。可以访问下 http://wdicc.com 看看效果，会自动跳转到 https://wdicc.com :D
