+++
title = "octopress and jeklly 1.0.1"
date = "2013-06-12T21:45:00+08:00"
comments = true
tags = ["linux", "web"]
description = ""
+++

自从 jeklly 1.0.x 发布之后，我的 octopress 站点就在 github，gitcafe 上面更新不了了，写了新帖子然后 push 之后，会收到个邮件，说 generate site faild。

等等。。这个不是静态站点吗？generate 你妹阿！！然后就找阿找阿找解决办法，尝试过下面这些

 - touch 一个 .nojeklly 不让它 generate
 - 找 octopress 支持 jeklly 1.0.1 的新版本
 - google 之，怎么可能就我遇到问题了呢
 - 使用 jeklly 1.0.1 单独搭一个，不用 octopress 了
 - ...其他忘记了的。。

悲剧的是，以上这些方法没一个搞定了

 * 某处搜到的这个 .nojeklly 完全不管用
 * octopress 2.1 这个 branch 支持 jeklly 1.0.1，可惜没能让他运转起来。。具体 release 日期似乎还没看到。。。
 * google 不到有用的信息，唯一有用的就是有人给 octopress 提的 pull request，可惜被 merge 到 2.1 了
 * 这个倒是简单，可惜的是 octopress 其实背后做了很多事情，单纯的拿弄 post 过去发现有些文件解析不了，我遇到的是 `` ``` `` 这个标记，是 octopress 支持的，可惜我的 post 里面好多都是这个。另外还有主题阿等等这些。

综上，就觉得，nnd，这破玩意怎么这么复杂？！

后来不知道哪天突然想到，我之前测试 hexo 的时候，它没有 jeklly 一说，不是也可以么？另外，github pages 的例子里面，也就是 echo 了一个文件呀，也没有 jeklly 阿，不是也可以么？然后就觉得豁然开朗，github 之流肯定是默认会给你处理 jeklly 的代码，然后产生一个 site，而不是直接使用你产生的 html 文件。回想之前每次 deploy github pages，都会收到一个邮件提醒说 site generate success 之类，那就应该是猜的没错了。

然后就开始尝试只 push html（octopress 的结果文件在 public 里面）上去，结果确实如所料，毛问题都没有了，gitcafe 和 github 都可以了。总算舒服了。。另外还写了一个使用 octopress deploy 到 gitcafe 的[帖子](http://wdicc.om/octopress-and-gitcafe/)，有需要可以参考。
