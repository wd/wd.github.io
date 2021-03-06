+++
date = "2017-07-24T20:02:00+08:00"
title = "Emacs as react native ide"
tags = ['emacs', 'react']
+++

最近又在写 `react-native` 了，对自己的环境又作了一番配置。记录一下。

## web-mode

我主要用的 mode 是 web-mode。这个 mode 简直万能，能处理 html，jsx，js 等。具体配置如下。

```
(use-package web-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.js\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.ejs\\'" . web-mode))
  (setq web-mode-markup-indent-offset 4)
  (setq web-mode-css-indent-offset 4)
  (setq web-mode-code-indent-offset 4)

  (setq web-mode-content-types-alist
        '(("jsx" . ".*\\.js\\'"))
        )
)

```

主要是那个 `web-mode-content-types-alist` 的配置，让 web-mode 处理 js 文件的时候，把 `<>` 代码段识别成 jsx。这样能把缩进处理好。

我还试过 rjsx-mode，这个用起来也可以，基于 js2-mdoe，js2-mode 有的一些用法都支持，并且 flycheck 都不用做多余的配置。但是主要问题是，jsx 的代码缩进有问题。

## flycheck

```
(use-package flycheck
  :ensure t
  :config
  (global-flycheck-mode t)
  (flycheck-add-mode 'javascript-eslint 'web-mode)
)

```

把 web-mode 的 checker 设置为 `javascript-eslint`，如果你用别的就设置成对应的。配合用的 .eslintrc 文件如下，可以根据自己需求调整。

```
{
    "parser": "babel-eslint",
    "env": {
        "es6": true
    },
    "parserOptions": {
        "ecmaVersion": 6,
        "sourceType": "module",
        "ecmaFeatures": {
            "jsx": true
        }
    },
    "plugins": [
        "react"
    ],
    "globals": {
        "require": false,
        "module": false,
        "setInterval": false,
        "clearInterval": false,
        "setTimeout": false,
        "clearTimeout": false,
        "console": false
    },
    "extends": [
        "eslint:recommended",
        "plugin:react/recommended"
    ],
    "rules": {
        // overrides
        "react/prop-types": 0,
        "indent": ["error", 4],
        "react/jsx-indent": ["error", 4],
        "no-trailing-spaces": 2,
        "no-console": 0,
        "comma-dangle": ["error", "never"]
    }
}

```

## 补全

```
(use-package tern
  :ensure t
  :config
  (add-hook 'web-mode-hook (lambda () (tern-mode t)))
  :bind (:map tern-mode-keymap
              ("M-*" . tern-pop-find-definition))
  )

(use-package company-tern
  :ensure t
  :config
  (add-to-list 'company-backends 'company-tern)
  )

```

我用的是 company 后端用的是 tern。.tern-project 的内容如下，可以根据自己的情况调整下。

```
{
  "ecmaVersion": 6,
  "libs": [
    "browser"
  ],
  "loadEagerly": [
    "Controller/*.js",
    "Utility/*.js",
    "App.js"
  ],
  "dontLoad": [
    "node_modules/**"
  ],
  "plugins": {
    "node": {},
    "es_modules": {},
    "jsx": {}
  }
}

```

## 补全 update

tern 这个东西用了一段时间，发现不是很好用。经常找不到 symbol，以及在 jsx 代码里面无法跳转。后来发现了 [tide](https://github.com/ananthakumaran/tide)，简直好用到不行。

tide 是基于 vscode 用的 tsserver 来搞的。这个开始是给 TypeScript 用的，目前也支持普通 js。

```
(defun setup-tide-mode ()
  (interactive)
  ;; (setq tide-tsserver-process-environment '("TSS_LOG=-level verbose -file /tmp/tss.log"))
  (tide-setup)
  ;;(setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1)
  ;; company is an optional dependency. You have to
  ;; install it separately via package-install
  ;; `M-x package-install [ret] company`
  )


(use-package tide
  :ensure t
  :bind (("M-." . tide-jump-to-definition)
         ("M-," . tide-jump-back)
         )

  :config
  (setup-tide-mode)
  ;; aligns annotation to the right hand side
  (setq company-tooltip-align-annotations t)

  ;; formats the buffer before saving
  ;;(add-hook 'before-save-hook 'tide-format-before-save)

  ;; configure javascript-tide checker to run after your default javascript checker
  (flycheck-add-next-checker 'javascript-eslint 'javascript-tide 'append)

  (add-hook 'web-mode-hook
            (lambda ()
              (when (string-equal "js" (file-name-extension buffer-file-name))
                (setup-tide-mode))))
  ;; configure jsx-tide checker to run after your default jsx checker
  (flycheck-add-mode 'javascript-eslint 'web-mode)
  (flycheck-add-next-checker 'javascript-eslint 'jsx-tide 'append)
  )


;; 针对 web-mode 做一个配置
    (add-hook 'web-mode-hook
            (lambda ()
              (set (make-local-variable 'company-backends)
                   '(
                      company-tide
                      ;company-react
                      company-dabbrev-code
                      company-keywords
                      company-files
                      company-yasnippet))))
```

其实我也没做啥配置，就是官方的那几个就可以。然后还有一个 jsconfig.json 的配置文件如下。

```
{
    "compilerOptions": {
        "allowJs": true,
        "allowSyntheticDefaultImports": true
    },
    "exclude": [
        "node_modules",
        "ios",
        "android",
        ".git"
    ]
}
```

这就支持了好多功能，比如光标停留在一个 keyword 上面就会高亮相关的，比如 company 的补全啥的，都很不错。还支持 refactor。
