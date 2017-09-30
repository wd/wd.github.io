+++
title = "cookie 的一点研究"
s = "about http cookie"
date = "2016-09-16T08:59:09+08:00"
tags = ["http", "cookie"]
description = ""
+++

这几天搞了一下 python 里面 cookie 相关的东西。我的目的是想要尝试用 python 登录某个网站，并且保持登录状态直到过期。因为 http 协议是无状态的，所以一般来讲，网站想要用户保持登录，那么网站在用户登录之后，必须要和用户端协商好怎么来证明这个用户已经登录过了。

用户端如果使用浏览器，那么网站就可以利用浏览器对 cookie 的支持来让用户在不知情的情况下，让网站在用户登录后发的一个 token 在用户后续的请求里面都包含上。

用户端如果不是浏览器，比如是个 python 程序，那么网站可以和用户协商每次请求里面都包含某个下发的 token（当然，甚至要求客户端每次请求都带着用户名密码也是可行的）。

但是如果网站本身只是给浏览器用户准备的，那么通过用程序来「模拟」浏览器行为，把必要的 token 保存并在后续的请求里面都带上，也是可行的。

python 里面，发送 http 请求可以简单的使用 `urllib.request.urlopen(url)`，但是如果想要定制一下请求，比如修改一些 header 信息，那么就得使用 `urllib.request.Request` 这个 class 先构造一个 Request 对象，然后传递给 urlopen 了。

如果要处理 cookie，那就需要使用 `http.cookiejar.CookieJar` 了，有了 Cookiejar 对象，就可以把网站下发的 cookie 保存到这个变量里面，然后在必要的时候，可以返回给服务器端了。如果想要保存到文件，那么可以使用 `http.cookiejar.LWPCookieJar` 或者 `http.cookiejar.MozillaCookieJar`，也可以基于 `http.cookiejar.FileCookieJar` 自己实现一个子类，来用自己的办法保存和加载 cookie，比如保存到数据库什么的，这样就可以多台机器之间共享 cookie 了。

`urlopen` 本身不支持自定义 cookiejar 逻辑，得使用 `opener = build_opener(HTTPCookieProcessor(cookiejar=Cookiejar对象))` 来先构造一个自定义的 openner, 然后使用 `opener(Request对象)` 来发送请求。

如果不定义自己的 cookie policy，那么会使用默认的 `http.cookiejar.DefaultCookiePolicy`，也可以自己基于 `http.cookiejar.CookiePolicy` 实现自己的逻辑。只需要 override `set_ok` 和 `return_ok` 这两个方法就可以。

http cookie 其实有很多属性，比如 domain, expire, path 等常见属性，也有 httponly, secure 等几个不常见的。这些属性都是浏览器处理的。就是说，浏览器把 cookie 返回给服务器端的时候，如果 domain 不匹配，或者已经过了 expire 时间等等一些不符合浏览器制定的 cookie 逻辑的时候，浏览器就不会把 cookie 发送给服务器端。就比如，服务器产生 cookie 的时候，声明了 domain=a.com，那么如果是来自于 b.com 的请求，浏览器是根本不会给他发送这个 cookie。再比如，服务器端产生 cookie 的时候，声明了 1 天后过期，那么 1 天之后，浏览器也不会再给服务器端发这个 cookie 了。

但是如果是我们自己实现客户端模拟浏览器的时候，其实我们是可以耍流氓的，可以制定自己的 cookie 逻辑，也就是上面提到的 cookie policy。比如我可以简单的在 `return_ok` 这个方法里面 `return True`，在任何情况下都把所有的 cookie 返回给服务器，这样服务器端如果不提前想明白，它是一点都不知道的。

所谓提前想明白就是想明白是不是需要针对这种情况做处理。如果本身我们系统也没有那么严格要求，那么不处理也可以。但是如果是某个比如金融系统，那么是必须要考虑的。否则如果完全依赖 cookie 的话，如果我通过某些手段弄到了用户的 cookie，那么我就可以骗过服务器端，让他认为我就是那个用户。

我想了一下，貌似被盗窃 cookie 这种事情服务器端不太好防范，但是可以做的是防止浏览器耍流氓。比如我们把 cookie 加密，并里面增加一个发送 cookie 的时间。收到客户端发过来的 cookie 之后，我们解密看看时间有没有过期，这样就可以在服务器端让 cookie 失效了。

另外，也可以考虑使用 session。session 是把一些用户的状态保存在服务器端。但是 session 实际上也是依赖 cookie 的，因为前面说了 http 协议无状态，就算可以把用户状态保存在服务器端，但是总还是得识别用户才可以。那个识别的 cookie 就是所谓的 session cookie，其实就是某个用户的唯一标识。

对于 session cookie 被窃，好像也没有太好的办法，无非也是想办法比对之前用户的一些状态信息，比如 ip 和现在的信息是不是一致，不一致可以认为有被窃的怀疑，这个时候让用户再次验证用户信息，这都不能 100% 保证，但是至少会增加窃贼的成本。

上面说到这些，都可以自己测试一下，测试也并不一定需要搭一个服务器端配合，以及使用复杂的抓包专鉴，其实使用 `nc` 就可以。

使用 `nc -l 9999` 就可以启动一个监听在 9999 端口的 socket 服务器。之后使用 python 或者 curl 之类的程序请求，就能立刻看到请求发送过来的 http 信息，这个对于学习 http 协议其实也很方便。

```
$ nc -l 9999
GET / HTTP/1.1
Accept-Encoding: identity
Connection: close
Cookie: QN2=test; QN1=ClbaCVfZF5lfszBALzTIAg==
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6)  AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36
Host: localhost:9999

```
收到的上面这个请求，可以看到发送过来了 2 个 cookie。

如果还想测试数据返回的情况，那么可以写一个 `test.resp` 文件，内容如下

```
$ cat test.resp
HTTP/1.1 200 OK
Date: Sun, 18 Oct 2009 08:56:53 GMT
Server: Apache/2.2.14 (Win32)
Last-Modified: Sat, 20 Nov 2004 07:16:26 GMT
ETag: "10000000565a5-2c-3e94b66c2e680"
Set-Cookie: QN1=ClbaCVfZF5lfszBALzTIAg==; expires=Thu, 31-Dec-37 23:55:55 GMT; path=/
Set-Cookie: QN2=test; expires=Thu, 31-Dec-37 23:55:55 GMT; path=/; secure; httponly
Accept-Ranges: bytes
Content-Length: 44
Connection: close
Content-Type: text/html
X-Pad: avoid browser bug

<html><body><h1>It works!</h1></body></html>
```

然后使用 `nc -l 9999 < test.resp` 命令启动服务，客户端来请求的时候，就会返回上面 `test.resp` 里面的内容。
