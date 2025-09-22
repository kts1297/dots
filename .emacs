;;; early-init.el --- Early startup (before UI & packages) -*- lexical-binding: t; -*-

;; Keep config in ~/.config/emacs/, but store *all* runtime data under ~/.emacs.d/
(setq user-emacs-directory (expand-file-name "~/.emacs.d/"))

;; Don't let package.el auto-initialize (we'll control it in init.el)
(setq package-enable-at-startup nil)

;; Faster startup; reset later in init.el
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; Minimal UI before init.el runs
(menu-bar-mode 1)
(scroll-bar-mode -1)
(tooltip-mode -1)

(setq frame-inhibit-implied-resize t
      inhibit-startup-screen t)

;;; init.el --- Main configuration -*- lexical-binding: t; -*-
;;;; Performance: restore sane GC after startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold 16777216  ; 16MB
                  gc-cons-percentage 0.1)))

(setq custom-file "~/.emacs.custom.el")
(load-file custom-file)

;;;; Basics
(setq inhibit-startup-message t
      ring-bell-function 'ignore
      use-short-answers t)              ; y/n prompts

(set-language-environment "UTF-8")
(global-display-line-numbers-mode 1)
(column-number-mode 1)
(delete-selection-mode 1)
;; Compile helpers
;; (setq compilation-read-command nil)         ; don't always ask
(global-set-key (kbd "<f5>") #'compile)     ; run compile
(global-set-key (kbd "<f6>") #'recompile)   ; repeat last compile

;;;; Centralize backups & autosaves into ~/.emacs.d/
;; Ensure backups and autosaves go into ~/.emacs.d/
(let ((backup-dir (expand-file-name "backups/" user-emacs-directory))
      (auto-saves-dir (expand-file-name "auto-saves/" user-emacs-directory)))
  (make-directory backup-dir t)
  (make-directory auto-saves-dir t)

  ;; Redirect backups (~ files)

  (setq backup-directory-alist `(("." . ,backup-dir))
        make-backup-files t
        backup-by-copying t
        version-control t
        kept-new-versions 10
        kept-old-versions 2
        delete-old-versions t)

  ;; Redirect auto-saves (# files#)
  (setq auto-save-file-name-transforms `((".*" ,auto-saves-dir t))
        auto-save-list-file-prefix (expand-file-name ".saves-" auto-saves-dir)))

;;;; Package management (simple, expandable)
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("gnu"   . "https://elpa.gnu.org/packages/")))
(package-initialize)

;; Bootstrap use-package if missing
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;;;; Example packages (safe to remove/expand)
(use-package magit :commands (magit-status))
(use-package which-key
  :ensure nil
  :config
  (which-key-mode 1))

(use-package whitespace
  :ensure nil ; built-in
  :hook (after-init . global-whitespace-mode)
  :config
  ;; Show spaces, tabs, and newline markers
  (setq whitespace-style '(face space-mark tab-mark newline-mark))

  ;; Define the glyphs/strings to use
  (setq whitespace-display-mappings
        '(
          ;; space → ·
          ;; (space-mark 32 [183] [46]) ; 183 is ·, fallback 46 is .
          ;; non-breaking space (nbsp) → ␣
          ;; (space-mark 160 [164] [95])
          ;; tab → » followed by space
          (tab-mark 9 [187 9] [92 9]) ; 187 is », fallback 92 is "\"
          ;; newline → ⏎
          (newline-mark 10 [8617 10] [36 10]) ; 8617 is ⏎, fallback $
          )))


;; Source for below: https://protesilaos.com/codelog/2024-02-17-emacs-modern-minibuffer-packages/
;; The `vertico' package applies a vertical layout to the minibuffer.
;; It also pops up the minibuffer eagerly so we can see the available
;; options without further interactions.  This package is very fast
;; and "just works", though it also is highly customisable in case we
;; need to modify its behaviour.
(use-package vertico
  :ensure t
  :config
  (setq vertico-cycle t)
  (setq vertico-resize nil)
  (vertico-mode 1))

;; The `marginalia' package provides helpful annotations next to
;; completion candidates in the minibuffer.  The information on
;; display depends on the type of content.  If it is about files, it
;; shows file permissions and the last modified date.  If it is a
;; buffer, it shows the buffer's size, major mode, and the like.
(use-package marginalia
  :ensure t
  :config
  (marginalia-mode 1))

;; The `orderless' package lets the minibuffer use an out-of-order
;; pattern matching algorithm.  It matches space-separated words or
;; regular expressions in any order.  In its simplest form, something
;; like "ins pac" matches `package-menu-mark-install' as well as
;; `package-install'.  This is a powerful tool because we no longer
;; need to remember exactly how something is named.
;;
;; Note that Emacs has lots of "completion styles" (pattern matching
;; algorithms), but let us keep things simple.
(use-package orderless
  :ensure t
  :config
  (setq completion-styles '(orderless basic)))

;; The `consult' package provides lots of commands that are enhanced
;; variants of basic, built-in functionality.  One of the headline
;; features of `consult' is its preview facility, where it shows in
;; another Emacs window the context of what is currently matched in
;; the minibuffer.  Here I define key bindings for some commands you
;; may find useful.  The mnemonic for their prefix is "alternative
;; search" (as opposed to the basic C-s or C-r keys).
(use-package consult
  :ensure t
  :bind (;; A recursive grep
         ("M-s M-g" . consult-grep)
         ;; Search for files names recursively
         ("M-s M-f" . consult-find)
         ;; Search through the outline (headings) of the file
         ("M-s M-o" . consult-outline)
         ;; Search the current buffer
         ("M-s M-l" . consult-line)
         ;; Switch to another buffer, or bookmarked file, or recently
         ;; opened file.
         ("M-s M-b" . consult-buffer)))

;; The `embark' package lets you target the thing or context at point
;; and select an action to perform on it.  Use the `embark-act'
;; command while over something to find relevant commands.
;;
;; When inside the minibuffer, `embark' can collect/export the
;; contents to a fully fledged Emacs buffer.  The `embark-collect'
;; command retains the original behaviour of the minibuffer, meaning
;; that if you navigate over the candidate at hit RET, it will do what
;; the minibuffer would have done.  In contrast, the `embark-export'
;; command reads the metadata to figure out what category this is and
;; places them in a buffer whose major mode is specialised for that
;; type of content.  For example, when we are completing against
;; files, the export will take us to a `dired-mode' buffer; when we
;; preview the results of a grep, the export will put us in a
;; `grep-mode' buffer.
(use-package embark
  :ensure t
  :bind (("C-." . embark-act)
         :map minibuffer-local-map
         ("C-c C-c" . embark-collect)
         ("C-c C-e" . embark-export)))

;; The `embark-consult' package is glue code to tie together `embark'
;; and `consult'.
(use-package embark-consult
  :ensure t)

;; The `wgrep' packages lets us edit the results of a grep search
;; while inside a `grep-mode' buffer.  All we need is to toggle the
;; editable mode, make the changes, and then type C-c C-c to confirm
;; or C-c C-k to abort.
(use-package wgrep
  :ensure t
  :bind ( :map grep-mode-map
          ("e" . wgrep-change-to-wgrep-mode)
          ("C-x C-q" . wgrep-change-to-wgrep-mode)
          ("C-c C-c" . wgrep-finish-edit)))

;; The built-in `savehist-mode' saves minibuffer histories.  Vertico
;; can then use that information to put recently selected options at
;; the top.
(savehist-mode 1)

;; The built-in `recentf-mode' keeps track of recently visited files.
;; You can then access those through the `consult-buffer' interface or
;; with `recentf-open'/`recentf-open-files'.
(recentf-mode 1)


;;;; Corfu: in-buffer completion UI
(use-package corfu
  :ensure t
  :hook ((after-init . global-corfu-mode)      ; enable everywhere
         (corfu-mode . corfu-popupinfo-mode))  ; inline docs/eldoc-style
  :custom
  (corfu-auto t)               ; show completions as you type
  (corfu-auto-prefix 2)        ; start after 2 chars
  (corfu-auto-delay 0.0)       ; no delay
  (corfu-cycle t)              ; cycle candidates
  (corfu-quit-no-match 'separator)
  (corfu-preselect 'prompt)
  (corfu-popupinfo-delay 0.2)
  ;; Nice Tab behavior: indent first, then complete
  (tab-always-indent 'complete)
  :bind
  (:map corfu-map
        ("M-j" . corfu-next)
        ("M-k" . corfu-previous)
        ("M-d" . corfu-popupinfo-toggle)
        ("RET" . nil)))         ; keep RET for newline unless you select explicitly

;; IMPORTANT: let Corfu own in-buffer completion UI.
;; If you previously set:
;;   (setq completion-in-region-function #'consult-completion-in-region)
;; comment/remove it so Corfu can take over. Corfu sets this when active.

;;;; Cape: extra completion sources for Corfu
(use-package cape
  :ensure t
  :init
  ;; Add useful capfs. Order matters (earlier = higher priority).
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)   ; words from buffers
  (add-to-list 'completion-at-point-functions #'cape-file)      ; file paths
  (add-to-list 'completion-at-point-functions #'cape-keyword)   ; language keywords
  (add-to-list 'completion-at-point-functions #'cape-symbol)    ; elisp symbols

  ;; Optional: super-capf that bundles several together (example)
  ;; (setq completion-at-point-functions
  ;;       (list (cape-super-capf #'cape-file #'cape-dabbrev #'cape-keyword)))
  )


;; (use-package go-mode
;;   :ensure t
;;   :mode ("\\.go\\'" . go-mode)
;;   :hook ((before-save . gofmt-before-save)))
;; (setq gofmt-command "goimports")


(use-package eglot
  :ensure t) ; on Emacs 30 this still pulls updates; built-in exists too

(add-hook 'go-mode-hook #'eglot-ensure)

;; Optional: use goimports on save
(setq gofmt-command "goimports")
(add-hook 'before-save-hook #'gofmt-before-save)
