+++
title = "python 的 decorator 学习"
s = "decorator in python"
date = "2016-10-21T18:50:59+08:00"
tags = ["python", "decorator"]
description = ""
+++


最近学习了一下 python 的 decorator（装饰器），看的是这篇，[Python修饰器的函数式编程](http://coolshell.cn/articles/11265.html)， 觉得挺有意思的，写点东西记录一下。

装饰器简单讲就是返回一个函数的函数/类。看个简单的例子。

``` python
#!/usr/bin/python
# -*- coding: utf-8 -*-


def dec1(fn):
    print('inside dec1')

    def wrapper():
        print('inside wrapper')
        return fn()
    return wrapper


@dec1
def f1():
    print('inside f1')

if __name__ == '__main__':
    print('begin exec')
    f1()
    print('end exec')

# 执行结果:
# inside dec1
# begin exec
# inside wrapper
# inside f1
# end exec
```

看上面例子能看到，装饰器生效有 2 个步骤，第一个是装饰，第二个是执行。上面装饰器的效果，和下面的代码的效果是一样。

``` python
#!/usr/bin/python
# -*- coding: utf-8 -*-


def dec1(fn):
    print('inside dec1')

    def wrapper():
        print('inside wrapper')
        return fn()
    return wrapper


# @dec1
def f1():
    print('inside f1')

if __name__ == '__main__':
    print('begin exec')
    dec1(f1)()
    print('end exec')

# 执行结果:
# begin exec
# inside dec1
# inside wrapper
# inside f1
# end exec
```

可以看到除了 「begin/end exec」，其他部分执行结果是一样的。所以理解装饰器，就把 `@dec1` 换成 `dec1(fn)()` 这么理解就可以了。

有时候会看到类也可以作为装饰器使用。其实理解起来也类似。举个例子。

``` python
#!/usr/bin/python
# -*- coding: utf-8 -*-


class dec1(object):
    def __init__(self, fn):
        print('inside dec1')
        self.fn = fn

    def __call__(self):
        print('inside wrapper')
        return self.fn()


@dec1
def f1():
    print('inside f1')

if __name__ == '__main__':
    print('begin exec')
    f1()
    print('end exec')

# 执行结果:
# inside dec1
# begin exec
# inside wrapper
# inside f1
# end exec
```

这里和上面类似，把 `@dec1` 理解成 `dec1(fn)()`，不过是这里的 `dec1` 是个类，那么 `dec1(fn)` 其实是调用的 `dec1.__init__(fn)`，那么后续的 `dec1(fn)()` 就是调用产生的对象的 `dec1.__call__()` 了。

有时候还能看到加了参数的装饰器。加了参数的是怎么回事呢。再看下面的例子。

``` python
#!/usr/bin/python
# -*- coding: utf-8 -*-


def dec1(name):
    print('inside dec1')

    def real_dec1(fn):
        def wrapper():
            print('inside wrapper')
            return fn()
        return wrapper
    return real_dec1


@dec1(name='1')
def f1():
    print('inside f1')

if __name__ == '__main__':
    print('begin exec')
    f1()
    print('end exec')

# 执行结果:
# inside dec1
# begin exec
# inside wrapper
# inside f1
# end exec
```

看懂了没有，就是多了个嵌套而已。遇到加了参数的，那就是把之前的没有参数的部分返回回来就可以了。等价的例子就不贴了，这个等价于 `dec1(name='1')(fn)()`。

如果是类装饰器，并且有参数，那等价于 `dec1(name='1')(fn)()`，其中 `__init__(self, name)` 先处理第一层参数，然后 `__call__(fn)` 处理第二层，然后需要在 `__call__` 里面再定义一个 wrapper 返回。

说明白没有？呵呵。

补充一点新的知识，来自于[这个视频](https://www.youtube.com/watch?v=MjHpMCIvwsY&list=PLPbTDk1hBo3y_yzy0ZIx_0PKlUiQ0WXG7&index=9)。

```python
@mydeco
def add(a, b):
    return a + b
```

上面这个等价于下面这个

```python
def add(a, b):
    return a + b
    
add = mydeco(add)
```

这里面三个 callable
1. 被装饰的函数 add
2. mydeco 装饰方法
3. 装饰方法返回的方法

装饰器可以做的事情：
1. timing，统计函数执行的时间。
2. 控制函数 60 秒执行一次。通过在 dec 方法内记录一个最后执行时间实现。
3. 类似上面的，可以任意指定限制的时间。只需要在上面的函数上面再套一层就可以。
4. 实现结果记忆。同样的输入，总是同样的输出，那可以按照输入参数记录执行结果，下次相同参数就不用再次执行了。
5. 给对象增加属性。可以装饰某给对象，然后增加一些属性，比如定制一下 `__repr__` 输出更好的内容。
6. 类似的，可以装饰某个对象，然后给他增加一些属性，比如增加一个 `__create_at` 这样的属性记录一下实例创建时间。
