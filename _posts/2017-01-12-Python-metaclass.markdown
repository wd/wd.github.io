title: Python metaclass
date: 2017-01-12 18:26:22
tags:
  - python
---
又理解了一下 python 的 metaclass 可以做什么，尝试记录一下。

```
class Meta(type):
    register = []

    def __new__(cls, class_name, parrent_class, params):
        print("In meta new: {}, {}, {}, {}".format(cls, class_name, parrent_class, params))
        cls.register.append(class_name)
        params['test_prop'] = True
        # return super(Meta, cls).__new__(cls, class_name, parrent_class, params)
        # return type.__new__(cls, class_name, parrent_class, params)
        # return super(Meta, cls).__new__(type, class_name, parrent_class, params)
        # return type.__new__(type, class_name, parrent_class, params)
        return type(class_name, parrent_class, params)

    def __init__(self, class_name, parrent_class, params):
        print("In meta init: {}, {}, {}".format(class_name, parrent_class, params))
        super(Meta, self).__init__(class_name, parrent_class, params)


class A(object, metaclass=Meta):
    pass

print("register: {}".format(Meta.register))
print("prop: {}".format(A.test_prop))
print("register: {}".format(A.register))  # Error

# outputs:
# In meta new: <class '__main__.Meta'>, A, (<class 'object'>,), {'__module__': '__main__', '__qualname__': 'A'}
# In meta init: A, (<class 'object'>,), {'__module__': '__main__', '__qualname__': 'A'}
# register: ['A']
# prop: True
# AttributeError: type object 'A' has no attribute 'register'

```

可以看到，在构造 `A` 的时候，`Meta` 这个类里面，`__new__` 和 `__init__` 都会被调用到。上面代码往 `A` 里面塞了一个属性。

在 `__new__` 里面，有几个注释，可以去掉注释看看不同的效果。目前还有点疑惑，传给 `__new__` 第一个参数到底是什么。另外，开始对 `super` 也有点疑惑了，还在学习。
