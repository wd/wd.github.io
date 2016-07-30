title: 基于 ffi 的 libmcrypt 加密模块
s: libmcrypt_ffi_module
date: 2015-07-05 20:55:11
tags:
---
openresty 提供了 luajit 的支持，luajit 又提供了 ffi 库的支持。通过 ffi 可以很方便的调用 c 库的一些方法。

我在项目里面用到了加解密，因为需要各语言支持，使用了 libmcrypt 库。之前通过 c 模块完成了在 lua 里面加密，在 perl 里面解密。有了 ffi 就可以使用纯 lua 模块搞定了。

代码写的比较丑，有使用加解密的需求的可以参考下，另外计划写其他模块的也可以参考下。如下

```
local ffi = require 'ffi'
local ffi_new = ffi.new
local ffi_str = ffi.string
local ffi_copy = ffi.copy
local setmetatable = setmetatable

local _M = { }
local mt = { __index = _M }

ffi.cdef[[
struct CRYPT_STREAM;
typedef struct CRYPT_STREAM *MCRYPT;

MCRYPT mcrypt_module_open(char *algorithm,
                          char *a_directory, char *mode,
                          char *m_directory);

int mcrypt_generic_init(const MCRYPT td, void *key, int lenofkey,
                        void *IV);

int mcrypt_generic_deinit(const MCRYPT td);
int mcrypt_generic_end(const MCRYPT td);
int mdecrypt_generic(MCRYPT td, void *plaintext, int len);
int mcrypt_generic(MCRYPT td, void *plaintext, int len);
int mcrypt_module_close(MCRYPT td);

]]

local mcrypt = ffi.load('libmcrypt.so.4')

_M.new = function (self)
    local cipher = 'blowfish'
    local mode = 'cbc'

    local c_cipher = ffi_new("char[9]", cipher)
    local c_mode = ffi_new("char[4]", mode)

    local td = mcrypt.mcrypt_module_open(c_cipher, nil, c_mode, nil)
    return setmetatable( { _td = td }, mt )
end

_M.encrypt = function(self, key, raw)
    local iv_len = 8
    local td = self._td

    local c_key = ffi_new("char[?]", #key+1, key)
    local c_iv = ffi_new("char[9]", key)
    local c_raw = ffi_new("char[?]", #raw+1, raw)

    mcrypt.mcrypt_generic_init(td, c_key, #key, c_iv)
    mcrypt.mcrypt_generic(td, c_raw, #raw )
    mcrypt.mcrypt_generic_deinit(td)

    return ffi_str(c_raw, ffi.sizeof(c_raw)-1)
end

_M.decrypt = function(self, key, raw)
    local iv_len = 8
    local td = self._td

    local c_key = ffi_new("char[?]", #key+1, key)
    local c_iv = ffi_new("char[9]", key)
    local c_raw = ffi_new("char[?]", #raw+1, raw)

    mcrypt.mcrypt_generic_init(td, c_key, #key, c_iv)
    mcrypt.mdecrypt_generic(td, c_raw, #raw )
    mcrypt.mcrypt_generic_deinit(td)

    return ffi_str(c_raw, ffi.sizeof(c_raw)-1)
end

_M.close = function(self)
    local td = self._td
    if td then
        mcrypt.mcrypt_module_close(td)
     end
end

return _M

```

使用方法比较简单，代码里面写死了是 `blowfish` 的 `cbc` 模式，并且 iv 使用 key 的前 8 个字符
```
local mcrypt = require "mcrypt"
local m = mcrypt:new()

-- 一系列加解密
local en = m:encrypt('xxx','yyyy')
...
local de = m:decrypt('xxx', yyyy')

-- 最后关闭
m:close()
```
