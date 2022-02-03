+++
date = "2017-03-11T16:29:40+08:00"
title = "Migrate blog to hugo"
tags = ["hugo", "hexo", "blog"]
+++

折腾了好几天，把 blog 从 hexo 迁移到了 [hugo](http://gohugo.io/) 上面。hexo 是使用 nodejs 写出来的，hugo 是使用的 go。主要基于下面几个原因吧。

* 个人不太喜欢 nodejs 那一坨依赖。
* hugo 也比 nodejs 速度快很多。
* hugo 用起来比较简洁。

首先写了一个迁移工具 [hexo2hugo](https://github.com/wd/hexo2hugo)。网上还有一个 nodejs 版本的[迁移工具](http://nodejh.com/post/Migrate-to-Hugo-from-Hexo/)可以参考。其实就是简单的把头部信息处理一下就可以。我还有一些特殊需求，比如把老早以前的一些 html 格式的文档顺道处理一下格式，还有一些小的修正和兼容工作，所以自己写了一个。另外也主要是好久没有写代码了，熟悉下。。

把文档迁移过去之后，找了几个主题看了一下，发现没有很喜欢的，就本着蛋疼的原则，把原来用的主题也[迁移过来了](https://github.com/wd/hugo-fabric)，这个花的时间比较长一点。主要还得熟悉 hugo 的模板语法，还得想办法适配 hugo 的体系。比如 hugo 里面没有 archive 一说，不过通过万能的 google 搜索到了一个解决办法，也勉强还好。

目前这个 blog 已经是由 hugo 产生了，和以前外观，访问地址完全一模一样，rss 地址都一样。我测试了 google 里面的搜索结果，是都可以跳转的。今天算是基本都迁移完毕了。

这几天没事也总想记录一点想法，但是无奈新本子上面的 hexo 挂了，又不想搞 nodejs 那一坨依赖，就折腾了这个事情。不过折腾完毕之后发现想记录的事情都忘记了，nnd。
