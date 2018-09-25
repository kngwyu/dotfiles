;;; init.el --- init file of Emacs.
;;; Commentary: kngwyu's init.el

;;; Code:
;;; speed up
(setq-default bidi-display-reordering nil)

;;; disable splash screen
(setq inhibit-splash-screen t)

;;; avoid duplication of history
(setq history-delete-duplicates t)

;;; uniquify buffer name
(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward-angle-brackets)
(setq uniquify-ignore-buffers-re "[^*]+")

;;; save where file was opend
(require 'saveplace)
(setq-default save-place t)
(setq save-place-file (concat user-emacs-directory "places"))

;;; highlight parentheses
(show-paren-mode 1)

;;; don't use TAB
(setq-default indent-tabs-mode nil)

;;; highlight current line
(global-hl-line-mode 1)

;;; save history of mini buffer
(savehist-mode 1)

;;; sync keybinding to shell
(global-set-key (kbd "C-h") 'delete-backward-char)

;;; auto-revert-mode
(global-auto-revert-mode 1)

;;; display line&column number
(line-number-mode 1)
(column-number-mode 1)

;;; reduce GC
(setq gc-cons-threshold (* 10 gc-cons-threshold))

(defalias 'yes-or-no-p 'y-or-n-p)

;;; theme
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes (quote (misterioso)))
 '(flycheck-display-errors-delay 0)
 '(package-selected-packages
   (quote
    (vue-mode py-yapf forest-blue-theme exotica-theme dracula-theme cython-mode company-jedi ox-reveal package-utils yaml-mode cuda-mode racer toml-mode f ## s clang-format magit helm-flycheck flycheck-pos-tip yatex undo-tree rust-mode markdown-mode helm-swoop helm-firefox helm-ag google-c-style flycheck-rust ddskk company-irony)))
 '(rust-format-on-save t)
 '(rust-indent-method-chain t))

;;; font
(set-face-attribute 'default nil :family "CamingoCode" :height 140)
(set-fontset-font t 'japanese-jisx0208 (font-spec :family "TakaoGothic" :height 110))

;;; Frame
(when window-system
  (progn
    (set-frame-parameter nil 'alpha 80)
    (set-frame-size (selected-frame) 100 50)
    (setq default-frame-alist
          (append '((width . 100) ;ウィンドウ幅
                    (height . 50) ;ウィンドウ高
                    (alpha . 80))
                  default-frame-alist))))

;;; customize alpha value
(defun set-alpha (alpha-num)
  "Set frame parameter alpha by ALPHA-NUM."
  (interactive "nAlpha: ")
  (set-frame-parameter nil 'alpha (cons alpha-num '(80))))
(setq make-backup-files nil)

;;; insert pairs
(electric-pair-mode t)

;;; configuration of packages
(package-initialize)
(setq package-archives
      '(("gnu" . "http://elpa.gnu.org/packages/")
        ("melpa" . "http://melpa.org/packages/")
        ("org" . "http://orgmode.org/elpa/")))

;;; set path other than elpa
(add-to-list 'load-path "/home/yu/Programs/emacs-racer/")
(add-to-list 'load-path "/home/yu/Programs/flycheck/")

;;; reveal.js
;;; (require 'ox-reveal)

;;; モードに関連しないキーバインドの変更
(global-set-key (kbd "<hiragana-katakana>") 'toggle-input-method)
(global-set-key (kbd "C-x g") 'magit-status)

;;; rustfmt
(let ((ld-lib-path (ignore-errors (car (process-lines "rustc" "--print" "sysroot")))))
  (when (and ld-lib-path (file-directory-p ld-lib-path))
    (setenv "LD_LIBRARY_PATH" (expand-file-name "lib" ld-lib-path))))

;;; custom
;  (setq custom-file (locate-user-emacs-file "custom.el"))
;;; C / C++
(require 'google-c-style)
(require 'irony)
(defun my-c++-mode-hook nil
  "Configure c++ mode."
  (progn
    (google-set-c-style)
    (google-make-newline-indent)
    (setq flycheck-gcc-language-standard "c++11")
    (setq flycheck-clang-language-standard "c++11")
    (irony-mode)
    (company-mode)))
  
(defun my-c-mode-hook nil
  "Configure c mode."
  (progn
    (google-set-c-style)
    (google-make-newline-indent)
    (irony-mode)
    (company-mode)))
(add-hook 'c-mode-hook (quote my-c-mode-hook))
(add-hook 'c++-mode-hook (quote my-c++-mode-hook))

(when (require 'clang-format) nil t
      (global-set-key (kbd "C-c i") 'clang-format-region)
      (global-set-key (kbd "C-c u") 'clang-format-buffer))

;;; mark down
(defun my-markdown-mode-hook nil
  (when buffer-file-name
    (add-hook 'after-save-hook
              'check-parens
              nil t)))
(add-hook 'markdown-mode-hook 'my-markdown-mode-hook)
;;; rust
(defun my-rust-mode-hook nil
  "Configure rust mode."
  (progn
    (custom-set-variables '(rust-indent-method-chain t))
    (custom-set-variables '(rust-format-on-save t))
    (racer-mode)))
(add-hook 'rust-mode-hook (quote my-rust-mode-hook))
(defun my-racer-mode-hook nil
   "Configure racer mode."
  (progn
    (eldoc-mode)
    (company-mode)))
(add-hook 'racer-mode-hook (quote my-racer-mode-hook))


;;; Coq
;; (load "~/.emacs.d/site-lisp/PG/generic/proof-site")

;;; slime
;; (setq inferior-lisp-program "/usr/bin/sbcl")
;; (add-to-list 'load-path "/usr/share/emacs/site-lisp/slime/")
;; (when (require 'slime nil 'noerror)
;;   (slime-setup))


;;; flycheck
(add-hook 'after-init-hook #'global-flycheck-mode)
(add-hook 'flycheck-mode-hook #'flycheck-rust-setup)
(with-eval-after-load 'flycheck
  (flycheck-pos-tip-mode)
  (define-key flycheck-mode-map (kbd "C-c h") 'helm-flycheck)
  (define-key flycheck-mode-map (kbd "M-n") 'flycheck-next-error)
  (define-key flycheck-mode-map (kbd "M-p") 'flycheck-previous-error)
  (custom-set-variables '(flycheck-display-errors-delay 0)))


;; Skk関連
;; Skk関連
(when (require 'skk nil t)
  (global-set-key (kbd "C-x j") 'skk-auto-fill-mode)
  (global-set-key (kbd "C-x C-j") 'skk-mode)
  (setq skk-show-candidates-nth-henkan-char 3)
  (setq skk-henkan-number-to-display-candidates 8)
  (setq skk-auto-insert-paren t)
  (setq skk-show-tooltip t)
  (setq skk-tooltip-parameters
        '((background-color . "dark blue")
          (border-color     . "alice blue")
          (foreground-color . "gray")
          (internal-border-width . 2)))
  (setq skk-dcomp-activate t)
  (require 'skk-study))

(defun my-skk-mode-hook nil
  "Configure skk mode."
  (if (eq major-mode 'yatex-mode)
      (progn
        (define-key skk-j-mode-map "\\" 'self-insert-command)
        (define-key skk-j-mode-map "$" 'YaTeX-insert-dollar))))
(add-hook 'skk-mode-hook (quote my-skk-mode-hook))

;; YaTeX configuration option
(when (autoload 'yatex-mode "yatex" "Yet Another LaTeX mode" t)
  (setq auto-mode-alist (cons '("\\.tex$" . yatex-mode) auto-mode-alist))
  (setq YaTeX-latex-message-code 'utf-8)
  (setq YaTeX-use-LaTeX2e t)
  (setq tex-command "latexmk -lualatex")
  (setq dvi2-command "evince"))

;;; helm
(when (require 'helm nil t)
  (helm-migemo-mode 1)
  (global-set-key (kbd "C-x b") #'helm-mini)
  (global-set-key (kbd "C-x C-f") #'helm-find-files)
  (global-set-key (kbd "C-x C-b") #'helm-buffers-list)
  (global-set-key (kbd "C-x r b") #'helm-filtered-bookmarks)
  (global-set-key (kbd "M-x") #'helm-M-x)
  (global-set-key (kbd "M-s o") #'helm-swoop)
  (global-set-key (kbd "M-y") #'helm-show-kill-ring)
  (global-set-key (kbd "C-M-g") #'helm-do-ag)
  (setq helm-ag-base-command "rg --vimgrep --no-heading")
  (setq dired-bind-jump nil)
  (require 'helm-config))

;;; irony-mode
(setq irony-lang-compile-option-alist
      (quote ((c++-mode . "c++ -std=c++11 -lstdc++")
              (c-mode . "gcc")
              (objc-mode . "objective-c"))))
(defun ad-irony--lang-compile-option nil
  ;; Company compile options.
  (defvar irony-lang-compile-option-alist)
  (let ((it (cdr-safe (assq major-mode irony-lang-compile-option-alist))))
    (when it (append '("-x") (split-string it "\s")))))
(advice-add 'irony--lang-compile-option :override #'ad-irony--lang-compile-option)
(add-hook 'irnony-mode-hook 'irony-cdb-autosetup-compile-options)
(require 'color)
;; color
(let ((bg (face-attribute 'default :background)))
  (custom-set-faces
   `(company-tooltip ((t (:inherit default :background ,(color-lighten-name bg 2)))))
   `(company-scrollbar-bg ((t (:background ,(color-lighten-name bg 10)))))
   `(company-scrollbar-fg ((t (:background ,(color-lighten-name bg 5)))))
   `(company-tooltip-selection ((t (:inherit font-lock-function-name-face))))
   `(company-tooltip-common ((t (:inherit font-lock-constant-face))))))

;; company
(with-eval-after-load 'company
  (define-key company-active-map (kbd "M-n") nil)
  (define-key company-active-map (kbd "M-p") nil)
  (define-key company-active-map (kbd "C-n") #'company-select-next)
  (define-key company-active-map (kbd "C-p") #'company-select-previous)
  (setq company-idle-delay 0)
  (setq company-minimum-prefix-length 2)
  (setq company-selection-wrap-around t)
  (add-to-list 'company-backends 'company-irony)
  (add-to-list 'company-backends 'company-jedi))

;;; python
(when (require 'jedi-core nil t)
  (setq jedi:complete-on-dot t)
  (setq jedi:use-shortcuts t)
  (setq flycheck-python-flake8-executable "python3")
  (add-hook 'python-mode-hook 'jedi:setup)
  (add-hook 'python-mode-hook 'company-mode)
  (add-hook 'python-mode-hook 'py-yapf-enable-on-save))


;;; browser
(setq browse-url-browser-function 'eww-browse-url)
(defvar eww-disable-colorize t)
(defun shr-colorize-region--disable (orig start end fg &optional bg &rest _)
  (unless eww-disable-colorize
    (funcall orig start end fg)))
(advice-add 'shr-colorize-region :around 'shr-colorize-region--disable)
(advice-add 'eww-colorize-region :around 'shr-colorize-region--disable)
(defun eww-disable-color ()
  "eww で文字色を反映させない"
  (interactive)
  (setq-local eww-disable-colorize t)
  (eww-reload))
(defun eww-enable-color ()
  "eww で文字色を反映させる"
  (interactive)
  (setq-local eww-disable-colorize nil)
  (eww-reload))

;;; undo-tree
;;; note: C-/ undo-tree-undo
;;;       C-x u undo-tree-visualize
(when (require 'undo-tree nil t)
  (global-undo-tree-mode 1)
  (global-set-key (kbd "C-\\") 'undo-tree-redo))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(company-scrollbar-bg ((t (:background "#415061"))))
 '(company-scrollbar-fg ((t (:background "#374352"))))
 '(company-tooltip ((t (:inherit default :background "#313c49"))))
 '(company-tooltip-common ((t (:inherit font-lock-constant-face))))
 '(company-tooltip-selection ((t (:inherit font-lock-function-name-face)))))
(require 'ox-reveal)
(provide 'init)
;;; init.el ends here
