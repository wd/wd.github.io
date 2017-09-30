+++
title = "use ivy to replace isearch"
date = "2016-01-10T19:22:20+08:00"
tags = ["emacs"]
description = ""
+++

之前习惯使用 `isearch` 来搜索了，最近看别人使用 `ivy` 看着心痒痒的，就想试试看。其实 ivy 的效果和 `swoop` 很像，不过区别是 ivy 是在 minibuffer 来显示可选信息的，swoop 是在一个 buffer 显示的。有洁癖的可能稍微计较一下。

```
;; ivy swiper
(defun wd-swiper-at-point ()
  "Pull next word from buffer into search string."
  (interactive)
  (let (query)
    (with-ivy-window
      (let ((tmp (symbol-at-point)))
        (setq query tmp)))
    (when query
      (insert (format "%s" query))
      )))

(use-package ivy
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t)
  (set-variable 'ivy-on-del-error-function '(lambda()))
  )

(use-package swiper
  :config
  (global-set-key "\C-s" 'swiper)
  (define-key swiper-map (kbd "C-w") 'wd-swiper-at-point)
  (define-key swiper-map (kbd "C-f") 'swiper-avy)
  )
```

我大致做了上面几个设定，`\C-s` 绑定了 swiper，启动 swiper 之后用 `\C-w` 可以快速把光标位置的 symbol 放到 minibuffer 来搜索。然后 swiper 和 isearch 有个区别是，默认情况下，swiper 如果 minibuffer 没有内容，按 backspace 会退出，这个和 isearch 的习惯不一样，把 `ivy-on-del-error-function` 重新绑定一下就可以了。

ivy 默认会绑定一个快捷键是在你 minibuffer 输入一些内容之后，会出来很多匹配结果，这个时候可以按 `C-'` 调用 `swiper-avy` 方便你快速定位，也挺好用的。不过我这里不好用，不知道怎么回事，只好重新绑定了一下。

还可以在 swiper 查询阶段按 `M-q` 进入替换模式。
