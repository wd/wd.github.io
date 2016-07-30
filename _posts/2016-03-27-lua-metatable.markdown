title: lua metatable
date: 2016-03-27 10:48:26
tags: lua
---

```
t = setmetatable({ bar = 4, foo = 7 }, { __index = { foo = 3 } })

print(t.foo)  -- 7
print(t.bar)  -- 4

t = setmetatable({  }, { __index = { foo = 3} })

print(t.foo)  -- 3
print(t.bar)  -- nil

fuc = function (t,k)
    if k == 'foo' then
        return rawget(t, 'bar')
    else
        return 0
    end
end

t = setmetatable({   }, { __index = fuc })

print(t.foo)  -- 3
print(t.bar)  -- nil
print(t.ff)
```
