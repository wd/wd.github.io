+++
title = "Python __new__"
date = "2017-01-16T15:47:59+08:00"
tags = ["python"]
description = ""
+++

翻译一点 https://www.python.org/download/releases/2.2/descrintro/#__new__ 有些感觉还是挺生硬的，方便自己理解吧。

`__new__` 的一些规则:

* `__new__` 是一个静态方法。定义它的时候并不需要执行 `__new__ = staticmethod(__new__)`，因为它的名字就包含了这个含义（这个对于类构造方法来说是个特殊的函数）
* `__new__` 的第一个参数，必须是一个类，其余的参数是留给构造方法的。
* 覆盖了基类的 `__new__` 方法的类有可能会调用基类的 `__new__` 方法。传递给基类的 `__new__` 方法的第一个参数，应该是覆盖基类的 `__new__` 方法的类，而不是基类，如果传递了基类，你得到的将是基类的示例。
* 除非你想要按照后面两条描述的方法来使用，否则 `__new__` 方法必须要调用基类的 `__new__` 方法，这个是创建你的对象的实例的唯一方法。子类的 `__new__` 方法可以从两个方面影响产生的实例：传递不同的参数给基类的 `__new__`，以及修改基类产生的对象（例如初始化一些实例变量）
* `__new__` 方法必须返回一个对象。并不一定必须返回一个新的对象，虽然通常都那么做。如果你返回一个已经存在的对象，依然会有对于 `__init__` 构造函数的调用。如果你返回一个其他函数的对象，那个对象的 `__init__` 也会被调用。如果忘记返回，python 会给你返回 None，你程序的调用方也许会觉得很奇怪。
* 对于不可变对象，`__new__` 可以返回一个之前缓存的对象。对于一些比较小的 int, str, tuple 类型就是这么做的。这也是为什么他们的 `__init__` 什么都没做：否则之前缓存的对象会被 init 很多次。（另外一个原因是本身页没有东西可以给 `__init__` 初始化的了，`__new__` 返回的就是一个已经初始化的对象）。
* 如果你想要给一个内置的不可变类型增加一些可变的状态（例如给 string 类型增加一个默认的转换方法），最好是在 `__init__` 方法里面初始化可变状态，而不要在 `__new__` 里面。
* 如果你想要修改构造方法的签名，一般需要覆盖 `__new__` 和 `__init__` 方法来接受心的签名。然而，大部分内置类型都会忽视自己不用的参数，尤其是不可变类型（int，long，float，complex，str，unicode，tuple）都有一个假的 `__init__`，而可变类型（dict，list，file，super，classmethod，staticmethd，property）有一个假的 `__new__`。内置类型 `object` 有假的 `__init__` 和 `__new__` （给其他对象继承）。内置类型 `type` 在很多方面都很特别，请参考 metaclasses。
* （这条和 `__new__` 没关系，但是页应该了解一下）如果新建一个 `type` 的子类，实例会自动给 `__dict__` 和 `__weakrefs__` 预留空间（ `__dict__` 在你使用前不会初始化，所以你不需要担心创建的所有实例被一个空的字典所占用的空间）。如果不需要这个多余的空间，可以给你的类设置 `__slots__ = []`（更多信息可以参考 `__slots__`。
* Factoid: `__new__` 是一个静态方法，不是类方法。我开始的时候觉得他应该是一个类方法，and that's why I added the classmethod primitive。不幸的是，对于一个类方法，在这种情况下面 upcalls 不工作，所以我只好把他设计成一个第一个参数是一个 class 的静态方法。讽刺的是，there are now no known uses for class methods in the Python distribution (other than in the test suite). I might even get rid of classmethod in a future release if no good use for it can be found!
