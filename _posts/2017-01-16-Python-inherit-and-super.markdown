title: Python inherit and super
date: 2017-01-16 11:53:04
tags:
  - python
  - super
  - inherit
---
又学习了一个 python 的继承。有很多帖子都有介绍，比如[理解 Python super](https://laike9m.com/blog/li-jie-python-super,70/)，[python super()](http://www.cnblogs.com/lovemo1314/archive/2011/05/03/2035005.html)。

先看一个例子，这个是第一个文章里面的。

```
class Root(object):
    def __init__(self):
        print("this is Root")


class B(Root):
    def __init__(self):
        print("enter B")
        super(B, self).__init__()
        print("leave B")


class C(Root):
    def __init__(self):
        print("enter C")
        super(C, self).__init__()
        print("leave C")


class D(C):
    def __init__(self):
        print("enter D")
        super(D, self).__init__()
        print("leave D")


class E(D, B):
    def __init__(self):
        print("enter E")
        super(E, self).__init__()
        print("leave E")

e = E()
print(e.__class__.mro())

# results:
# enter E
# enter D
# enter C
# enter B
# this is Root
# leave B
# leave C
# leave D
# leave E
# [<class '__main__.E'>, <class '__main__.D'>, <class '__main__.C'>, <class '__main__.B'>, <class '__main__.Root'>, <class 'object'>]
```

没有什么问题，所有的类都做了初始化，很完美。接着再看一个例子，这个例子其实是上面第二篇文章里面的。

```
class A(object):
    def __init__(self):
        print("enter A")
        print("leave A")


class B(object):
    def __init__(self):
        print("enter B")
        print("leave B")


class C(A):
    def __init__(self):
        print("enter C")
        super(C, self).__init__()
        print("leave C")


class D(A):
    def __init__(self):
        print("enter D")
        super(D, self).__init__()
        print("leave D")


class E(B, C):
    def __init__(self):
        print("enter E")
        super(E, self).__init__()
        print("leave E")


class F(E, D):
    def __init__(self):
        print("enter F")
        super(F, self).__init__()
        print("leave F")


f = F()
print(f.__class__.mro())

# results:
# enter F
# enter E
# enter B
# leave B
# leave E
# leave F
# [<class '__main__.F'>, <class '__main__.E'>, <class '__main__.B'>, <class '__main__.C'>, <class '__main__.D'>, <class '__main__.A'>, <class 'object'>]
```

我发现和文章里面贴的结果不一样，里面缺少对 C，D，A 的初始化。琢磨半天才弄明白，主要原因就是，`A`，`B` 其实也是继承自 `object`，然而我们并没有调用 `super` 来初始化，所以只需要加上就可以了。

```
class A(object):
    def __init__(self):
        print("enter A")
        super(A, self).__init__()
        print("leave A")


class B(object):
    def __init__(self):
        print("enter B")
        super(B, self).__init__()
        print("leave B")


class C(A):
    def __init__(self):
        print("enter C")
        super(C, self).__init__()
        print("leave C")


class D(A):
    def __init__(self):
        print("enter D")
        super(D, self).__init__()
        print("leave D")


class E(B, C):
    def __init__(self):
        print("enter E")
        super(E, self).__init__()
        print("leave E")


class F(E, D):
    def __init__(self):
        print("enter F")
        super(F, self).__init__()
        print("leave F")


f = F()
print(f.__class__.mro())

# results:
# enter F
# enter E
# enter B
# enter C
# enter D
# enter A
# leave A
# leave D
# leave C
# leave B
# leave E
# leave F
# [<class '__main__.F'>, <class '__main__.E'>, <class '__main__.B'>, <class '__main__.C'>, <class '__main__.D'>, <class '__main__.A'>, <class 'object'>]
```

这样就完美了。目测这个会是一个隐藏的坑。
