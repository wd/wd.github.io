title: Release some staff at github
date: 2016-12-13 17:00:31
tags:
 - hexo
 - lua
 - ngx_lua
 - mcrypt
---
把 blog 用到的模板整理了一下，放到了 https://github.com/wd/hexo-fabric ，这个最开始是 fork 别人的代码改的，后来发现原来那个人已经不用了，就整理一下，增加了一个 tag 支持，修改了一下字体和背景色，还有代码颜色等，都是一些小修改。同时也提交到了官方的 theme 库，不过 pull request 还没有通过。。

另外，还把之前写的一个给 ngx-lua 用的一个使用 mcrypt 加密解密的库 https://github.com/wd/lua-resty-mcrypt ，整理出来单独弄了一个模块。代码其实非常简单，这个也能看出来 ngx_lua 里面使用 ffi 调用 C 模块开发多舒服，不过因为 C 知识有限，可能还是会有一些问题，不过至少自己测试是 ok 的，也在线上跑了好久，只能遇到有问题的再说了。这个同时也提交到了春哥的 opm 仓库，那个倒没有审核，提交就被索引了，使用的话应该可以用 opm 命令直接安装。
