;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; basic configure
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; directories
(defvar home-dir (expand-file-name "~/"))
(defvar user-dir user-emacs-directory)
(defvar temp-dir (concat user-dir ".cache/"))
(defvar elpa-dir (concat user-dir "elpa/"))
(unless (file-exists-p temp-dir)
  (make-directory temp-dir t))

;; exec path
(if (eq system-type 'windows-nt)
    (add-to-list 'exec-path (concat home-dir "AppData/Roaming/emacs/bin/")))

;; proxy
(when nil
  (setq url-proxy-services
	'(("no_proxy" . "^\\(localhost\\|192\\.168\\..*\\)")
	  ("http" . "proxy.com:8080")
	  ("https" . "proxy.com:8080"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; package management
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; straight
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-dir))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))
(setq straight-use-package-by-default t)

;; use package
(eval-when-compile
  (unless (require 'use-package nil t)
    (straight-use-package 'use-package)))

;; load path
(when nil
  (let ((default-directory (concat user-dir "lisp/")))
    (normal-top-level-add-to-load-path '("."))
    (normal-top-level-add-subdirs-to-load-path)))

;; diminish mode name on modeline
(use-package delight)

;; bind-key
(use-package bind-key)

;; reload .emacs
(defun b/reload-dotemacs-file()
  "reload .emacs"
  (interactive)
  (when (y-or-n-p "Rebuild Packages?")
    (byte-recompile-directory user-emacs-directory 0))
  (when (file-exists-p (expand-file-name ".emacs.elc" home-dir))
    (delete-file (expand-file-name ".emacs.elc" home-dir)))
  (byte-compile-file (expand-file-name ".emacs" home-dir))
  (load-file (expand-file-name ".emacs.elc" home-dir)))
(global-set-key (kbd "C-c C-l") 'b/reload-dotemacs-file)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; server
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; server
(use-package server
  :disabled
  :delight (server-buffer-clients "Ⓢ")
  :config
  (server-mode 1)

  ;; use tcp server
;  (setq server-use-tcp t
;	server-host "ip")

  ;; start server
  (unless (server-running-p) (server-start)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; display
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; main frame
(setq inhibit-startup-message t)	; disable startup message
(menu-bar-mode -1)			; hide menu bar
(tool-bar-mode -1)			; hide tool bar
;(scroll-bar-mode -1)			; hide scroll bar
(auto-image-file-mode t)		; show inline image
(global-auto-revert-mode t)		; auto refresh
;(global-linum-mode)			; line number

;; mode line
(line-number-mode t)			; display line number in mode line
(column-number-mode t)			; display column number in mode line
(size-indication-mode t)		; display file size in mode line

;; fonts
(create-fontset-from-fontset-spec
 "-monotype-courier-medium-r-normal-*-*-130-*-*-m-*-fontset-frame,
 korean-ksc5601:-hanyang-gothic-medium-r-normal-*-*-150-*-*-*-*-ksc5601*-0,
 japanese-jisx0208:-ricoh-gothic-medium-r-normal-*-*-150-*-*-*-*-jisx0208*-0,
 japanese-jisx0212:-ricoh-mincho-medium-r-normal-*-*-150-*-*-*-*-jisx0212*-0,
 chinese-big5-1:-dynalab-ming-medium-r-normal-*-*-150-*-*-*-*-big5*-0,
 chinese-big5-2:-dynalab-ming-medium-r-normal-*-*-150-*-*-*-*-big5*-0,
 chinese-gb2312:-zhuhai-song-medium-r-normal-*-*-150-*-*-*-*-gb2312*-*,
 thai-tis620:-*-fixed-medium-r-normal-*-*-160-*-*-*-*-tis620.2529-1,
 vietnamese-viscii-lower:-monotype-courier-medium-r-normal-*-*-130-*-*-*-*-viscii1.1-1,
 lao:-*-fixed-medium-r-normal-*-*-160-*-*-*-*-mulelao-1,
 indian-is13194:-*-fixed-medium-r-normal-*-*-160-*-*-*-*-is13194-devanagari,
 indian-1-column:-*-fixed-medium-r-normal-*-*-160-*-*-*-*-muleindian-1,
 indian-2-column:-*-fixed-medium-r-normal-*-*-160-*-*-*-*-muleindian-2")
(set-fontset-font "fontset-frame" 'latin
		  (font-spec :name "D2Coding" :size 16))
(set-fontset-font "fontset-frame" 'han
		  (font-spec :name "Noto Sans Mono CJK SC" :size 16))
(set-fontset-font "fontset-frame" 'kana
		  (font-spec :name "Noto Sans Mono CJK JP" :size 16))
(set-fontset-font "fontset-frame" 'hangul
		  (font-spec :name "Noto Sans Mono CJK KR" :size 16))
(set-face-font 'default "fontset-frame")
(set-face-attribute 'default nil
		    :font "fontset-frame"
		    :height 120)
(add-to-list 'default-frame-alist '(font . "fontset-frame"))	;; for daemon
(add-to-list 'face-font-rescale-alist '("*" . 1.0))

;; theme
(use-package monokai-theme
  :config
  (load-theme 'monokai t))

;; fill column indicator
(use-package fill-column-indicator
  :config
  (setq fci-rule-width 1)
  (setq fci-rule-color "dark blue")
  (setq-default fill-column 80)
  (add-hook 'after-change-major-mode-hook 'fci-mode))

;; toggle word wrap
(global-set-key (kbd "C-t") 'toggle-truncate-lines)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; language
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; default encoding
(set-language-environment "utf-8")
(set-default-coding-systems 'utf-8)
(set-file-name-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(modify-coding-system-alist 'file "" 'utf-8-unix)

;; locale
(setq system-time-locale "C")

;; input method
(setq default-input-method "korean-hangul")
(global-set-key [?\S- ] 'toggle-input-method)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; save
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; auto saving
(setq backup-inhibited t		; disable backaup
      auto-save-default nil		; disable auto save
      auto-save-list-file-prefix temp-dir)

;; save last position
(save-place-mode t)
(setq save-place-file (expand-file-name "places" temp-dir)
      save-place-forget-unreadable-files nil)

;; save recent files
(recentf-mode t)
(setq recentf-save-file (expand-file-name "recentf" temp-dir))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; highlight
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; highlight current line
(global-hl-line-mode 1)
(set-face-foreground 'highlight nil)
(set-face-background 'highlight "#444444")
(set-face-underline  'highlight nil)

;; empty line
(setq indicate-empty-lines t)

;; whitespace
(use-package whitespace
  :delight (global-whitespace-mode "Ⓦ")
  :config
  (global-whitespace-mode 1)
  (setq whitespace-style
	'(face spaces tabs newline space-mark tab-mark newline-mark))
  (setq whitespace-display-mappings
	'(
	  (space-mark 32 [183] [46])	; space 32 「 」, 183 moddle dot 「·」,
					; 46 full stop 「.」
	  (newline-mark 10 [182 10])	; newline
	  (tab-mark 9 [8614 9] [92 9])	; tab
	  )))

;; highlight current word
(defvar highlight-current-word-color-index
  0
  "highlight color index")
(defvar highlight-current-word-color-list
  (list 'hi-yellow 'hi-pink 'hi-blue 'hi-green 'hi-red)
  "highlight color list")
(defun highlight-current-word()
  "highlight current word"
  (interactive)
  (highlight-regexp (current-word) (nth highlight-current-word-color-index
					highlight-current-word-color-list))
  (incf highlight-current-word-color-index)
  (when (= highlight-current-word-color-index 4)
    (setq highlight-current-word-color-index 0)))
(defun unhighlight-current-word()
  "unhighlight current word"
  (interactive)
  (unhighlight-regexp (current-word)))

(global-set-key (kbd "C-=") 'highlight-current-word)
(global-set-key (kbd "C--") 'unhighlight-current-word)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; paren
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; show paren
(use-package paren
  :config
  (show-paren-mode t)
  (setq show-paren-style 'mixed)
  (set-face-attribute 'show-paren-match nil
		      :background "blue"))

;; smartparens
(use-package smartparens
  :delight (smartparens-mode "Ⓟ")
  :config
  (smartparens-global-mode t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; etc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; selection
(cua-mode t)
(setq cua-enable-cua-keys nil)
(global-set-key (kbd "C-SPC")     'set-mark-command)
(global-set-key (kbd "<C-kanji>") 'set-mark-command)

;; ediff
(setq ediff-window-setup-function 'ediff-setup-windows-plain
      ediff-split-window-function 'split-window-horizontally)

;; yes/no to y/n
(defalias 'yes-or-no-p 'y-or-n-p)

;; which-key
(use-package which-key
  :delight (which-key-mode "Ⓚ")
  :config (which-key-mode))

;; eldoc
(use-package eldoc
  :defer t
  :delight (eldoc-mode "Ⓓ"))

;; auto complete
(use-package auto-complete
  :defer t
  :delight (auto-complete-mode "Ⓐ"))

;; auto correction
(use-package abbrev
  :straight nil
  :defer t
  :delight (abbrev-mode "Ⓑ"))

;; dired
(use-package dired
  :straight nil
  :defer t
  :config
  (put 'dired-find-alternate-file 'disabled nil)
  (define-key dired-mode-map (kbd "RET") 'dired-find-alternate-file)
  (define-key dired-mode-map (kbd "^")
    (lambda () (interactive) (find-alternate-file ".."))))

;; async
(use-package async
  :defer t
  :init
  (autoload 'dired-async-mode "dired-async.el" nil t)
  (dired-async-mode 1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; helm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; helm
(use-package helm
  :defer t
  :delight (helm-mode "Ⓗ")
  :config
  (helm-mode t)
  (helm-autoresize-mode t)

  (when (executable-find "curl")
    (setq helm-net-prefer-curl t))

  (setq helm-split-window-inside-p t
	helm-move-to-line-cycle-in-source t
	helm-ff-search-library-in-sexp t
	helm-scroll-amount 8
	helm-M-x-fuzzy-match t
	helm-buffers-fuzzy-matching t
	helm-recentf-fuzzy-match t
	helm-ff-file-name-history-use-recentf t)

  (global-unset-key (kbd "C-x c"))

  :bind
  (("C-c h"   . helm-command-prefix)
   ("C-h"     . helm-command-prefix)
   ("M-x"     . helm-M-x)
   ("M-y"     . helm-show-kill-ring)
   ("C-x b"   . helm-mini)
   ("C-x C-f" . helm-find-files)
   ("C-, ,"   . helm-resume)
   :map helm-map
   ("<tab>"   . helm-execute-persistent-action)
   ("C-i"     . helm-execute-persistent-action)
   ("C-z"     . helm-select-action)))

;; helm-ag
(use-package helm-ag
  :defer t
  :config
  (setq helm-ag-base-command "rg --vimgrep --no-heading --smart-case")
  (setq helm-ag-insert-at-point 'symbol)
  :bind
  (("C-, aa" . helm-do-ag-project-root)
   ("C-, ad" . helm-do-ag)
   ("C-, af" . helm-do-ag-this-file)
   ("C-, ab" . helm-do-ag-buffers)
   ("C-, ao" . helm-ag-pop-stack)))

;; helm-google
(use-package helm-google
  :defer t
  :bind ("C-c g" . helm-google))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; cscope
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; xcscope
(use-package xcscope
  :defer t)

;; helm-cscope
(use-package helm-cscope
  :defer t
  :delight (helm-cscope-mode "Ⓒ")
  :init
  (add-hook 'c-mode-common-hook 'helm-cscope-mode)
  :config
  ;; disable auto database update
  (setq cscope-option-do-not-update-database t)
  :bind
  (:map c-mode-base-map
   ("C-, cs" . helm-cscope-find-this-symbol)
   ("C-, cg" . helm-cscope-find-global-definition)
   ("C-, cd" . helm-cscope-find-called-this-function)
   ("C-, cc" . helm-cscope-find-calling-this-function)
   ("C-, ct" . helm-cscope-find-this-text-string)
   ("C-, ce" . helm-cscope-find-egrep-pattern)
   ("C-, cf" . helm-cscope-find-this-file)
   ("C-, ci" . helm-cscope-find-files-including-file)
   ("C-, co" . helm-cscope-pop-mark)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; C/C++
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; style
(setq c-default-style "bsd"
      c-basic-offset 8)
(which-function-mode 1)

;; tab
(add-hook 'c-mode-common-hook
	  (lambda ()
	    (setq-default indent-tabs-mode t
			  tab-width 8
			  tab-always-indent t)
	    (setq indent-tabs-mode t
		  tab-width 8
		  tab-always-indent t)))

;; auto-correction
(when (featurep 'abbrev)
  (add-hook 'c-mode-common-hook (function (lambda nil (abbrev-mode 1)))))

;; compile
(setq compilation-scroll-output 'first-error)
(eval-when-compile
  (defvar work-directory)
  (defvar backup-directory))

(defun compile-default-directory ()
  (interactive)
  (setq work-directory default-directory)
  (call-interactively 'compile))

(defun compile-work-directory ()
  (interactive)
  (if (boundp 'work-directory) nil
    (setq work-directory default-directory))
  (setq backup-directory default-directory)
  (setq default-directory work-directory)
  (call-interactively 'compile)
  (setq default-directory backup-directory))

(global-set-key "\C-c\C-m" 'compile-default-directory)
(global-set-key "\C-cm"    'compile-work-directory)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; python
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; python
(use-package python
  :defer t
  :config
  (add-hook 'python-mode-hook
	    (lambda ()
	      (setq indent-tabs-mode t
		    python-indent-offset 8
		    tab-width 8
		    tab-always-indent t))))

;; jupyter
(use-package skewer-mode
  :defer t)
(use-package ein
  :defer t
  :config
  (setq request-backend 'url-retrieve)
  (setq ein:jupyter-default-server-command "jupyter"
	ein:jupyter-server-args (list "--no-browser")
	ein:jupyter-default-notebook-directory "~/src/jupyter"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; org
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; org
(use-package org
  :defer t
  :config
  ;; basic
  (add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
  (add-to-list 'org-emphasis-alist '("*" (:foreground "red")))
  (setq org-todo-keywords
	'((sequence "TODO(t)" "WAIT(w)" "|" "DONE(d)" "DROP(p)"))
	org-hide-leading-stars t
	org-startup-indented t)

  (custom-set-faces '(org-level-1 ((t (:height 1.0))))
		    '(org-level-2 ((t (:height 1.0))))
		    '(org-level-3 ((t (:height 1.0))))
		    '(org-level-4 ((t (:height 1.0))))
		    '(org-level-5 ((t (:height 1.0))))
		    '(org-level-6 ((t (:height 1.0)))))

  ;; image
  (setq org-startup-with-inline-images t	; show inline image
	org-image-actual-width			; resize inline image (1/3)
	(/ (display-pixel-width) 3))

  ;; agenda
  (defvar org-agenda-dir (concat home-dir "Org/Task/"))
  (setq org-agenda-files
	(directory-files-recursively org-agenda-dir "\\.org$")
	org-agenda-show-all-dates nil		; hide empty day
	org-agenda-start-on-weekday 0		; agenda starts on sunday
	org-agenda-span 31			; number of days for agenda
	org-agenda-time-leading-zero t
	org-agenda-skip-scheduled-if-deadline-is-shown 'not-today
	org-agenda-skip-scheduled-if-done t
	org-agenda-skip-deadline-if-done t
	org-agenda-skip-timestamp-if-done t
	org-agenda-todo-ignore-scheduled 'future
	org-agenda-todo-ignore-deadlines nil
	org-agenda-todo-ignore-timestamp t
	org-agenda-tags-todo-honor-ignore-options t)

  ;; custom agenda
  (defun b/org-agenda-skip-if-scheduled-later ()
    "If this functino returns nil, the current match should not be skipped"
    (ignore-errors
      (let ((subtree-end (save-excursion (org-end-of-subtree t)))
	    (scheduled-seconds
	     (time-to-seconds
	      (org-time-string-to-time
	       (org-entry-get nil "SCHEDULED"))))
	    (now (time-to-seconds (current-time))))
	(and scheduled-seconds
	     (>= scheduled-seconds now)
	     subtree-end))))
  (setq org-agenda-custom-commands
	'(("w" "Agenda + Todo"
	   ((agenda ""
		    ((org-agenda-overriding-header "Agenda:")
		     (org-agenda-skip-function 'b/org-agenda-skip-if-scheduled-later)
		     (org-agenda-skip-scheduled-if-deadline-is-shown 'not-today)
		     (org-agenda-span 1)))
	    (agenda ""
		    ((org-agenda-overriding-header "")
		     (org-agenda-skip-function '(org-agenda-skip-entry-if 'notscheduled))
		     (org-agenda-skip-scheduled-if-deadline-is-shown 'not-today)
		     (org-agenda-start-day "+1d")))
	    (todo ""
		  ((org-agenda-todo-ignore-scheduled 'future)))))))

  ;; capture
  (defvar org-agenda-inbox-file (expand-file-name "Inbox.org" org-agenda-dir))
  (setq org-capture-templates
	'(("t" "todo" entry
	   (file+headline
	    (lambda () (expand-file-name "Inbox.org" org-agenda-dir))
	    "Inbox") "* TODO %i%?")
	  ("p" "project" entry
	   (file+headline
	    (lambda () (expand-file-name "Project.org" org-agenda-dir))
	    "Tasks") "* TODO %i%?\n%t")
	  ("w" "wait" entry
	   (file+headline
	    (lambda () (expand-file-name "Wait.org" org-agenda-dir))
	    "Wait") "* WAIT %i%?\n%u")))

  ;; refile
  (setq org-refile-targets
	'((nil :maxlevel . 1)
	  (org-agenda-files :maxlevel . 1)))

  ;; babel
  (if (>= emacs-major-version 26)
      (org-babel-do-load-languages
       'org-babel-load-languages
       '((emacs-lisp . t)
	 (shell . t)
	 (latex . t)
	 (dot . t)
	 (R . nil)))
    (org-babel-do-load-languages
     'org-babel-load-languages
     '((emacs-lisp . t)
       (sh . t)
       (latex . t)
       (dot . t)
       (R . nil))))

  (add-hook 'org-mode-hook
	    (lambda ()
	      (setq-default indent-tabs-mode nil
			    tab-width 8
			    tab-always-indent nil)
	      (setq indent-tabs-mode nil
		    tab-width 8
		    tab-always-indent nil)))

  ;; beamer
  (add-to-list 'org-latex-packages-alist '("" "listings" nil))
  (setq org-latex-listings t
	org-latex-listings-options '(("basicstyle" "\\tiny")
				     ("frame" "single")
				     ("keywordstyle" "\\color{cyan}")
				     ("stringstyle" "\\color{orange}")
				     ("commentstyle" "\\color{gray}")
				     ("frame" "noney")
				     ("breaklines" "true")))

  (defun b/org-agenda-redo ()
    (interactive)
    (setq org-agenda-files
	  (directory-files-recursively org-agenda-dir "\\.org$"))
    (org-agenda-redo t))
  :bind
  (("\C-ca" . org-agenda)
   ("\C-cl" . org-store-link)
   ("\C-cc" . org-capture)
   ("\C-cb" . org-iswitchb)
   ("\C-cr" . org-remember)
;   :map org-agenda-mode-map
;   ("r" . b/org-agenda-redo)
   ))

(use-package org-indent
  :straight nil
  :defer t
  :delight (org-indent-mode "Ⓘ"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; calendar
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq calendar-week-start-day 0)	; 0:Sunday, 1:Monday

;; korean holidays
(use-package korean-holidays
  :defer t
  :config
  (setq calendar-holidays korean-holidays))

;; calfw
(use-package calfw
  :defer t)

;; calfw-org
(use-package calfw-org
  :defer t
  :config
  ;; remove warning message from compiler
  (declare-function org-bookmark-jump-unhide "org")
  :bind ("C-c f" . cfw:open-org-calendar))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; markdown
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; markdown
(use-package markdown-mode
  :defer t
  :delight
  (markdown-mode "Ⓜ")
  (gfm-mode "Ⓜ")
  :config
  (autoload 'markdown-mode "markdown-mode" "Markdown" t)
  (autoload 'gfm-mode "markdown-mode" "GitHub Flavored Markdown" t)
  (add-to-list 'auto-mode-alist '("\\.md\\'" . gfm-mode))

  (add-hook 'markdown-mode-hook
	    (lambda ()
	      (setq-default indent-tabs-mode nil
			    tab-width 8
			    tab-always-indent nil)
	      (setq indent-tabs-mode nil
		    tab-width 8
		    tab-always-indent nil))))

;; markdown preview
(use-package markdown-preview-mode
  :defer t
  :config
  (setq browse-url-browser-function 'browse-url-firefox
	browse-url-new-window-flag  t
	browse-url-firefox-new-window-is-tab t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; latex
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; auctex
(use-package auctex
  :defer t
  :config
  (load "auctex.el" nil t t))

;; latex preview pane
(use-package latex-preview-pane
  :defer t
  :config
  (latex-preview-pane-enable))

;; doc view
(use-package doc-view
  :defer t
  :config
  (setq doc-view-resolution 240)
  (setq doc-view-continuous t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; version control system
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; magit
(use-package magit
  :defer t)

;; git-gutter
(use-package git-gutter
  :delight (git-gutter-mode "Ⓖ")
  :config (global-git-gutter-mode t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; check & build
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; gradle
(use-package gradle-mode
  :defer t
  :delight (gradle-mode "Ⓡ")
  :config
  (gradle-mode 1))

;; flymake
(use-package flymake
  :delight (flymake-mode "Ⓕ"))

;; ispell
(use-package ispell)

;; flyspell
(use-package flyspell
  :requires ispell
  :delight (flyspell-mode "Ⓕ")
  :config
  (add-hook 'org-mode-hook
	    (lambda ()
	      (if (eq system-type 'windows-nt)
		  (setq ispell-program-name
			"C:/Program Files (x86)/Aspell/bin/aspell"))
	      (flyspell-mode 1))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; mail
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; w3m
(use-package w3m
  :defer t
  :config
  (autoload 'w3m "w3m" "Interface for w3m on Emacs." t)
  (autoload 'w3m-find-file "w3m" "w3m interface function for local file." t)
  (autoload 'w3m-browse-url "w3m" "Ask a WWW browser to show a URL." t)
  (autoload 'w3m-search "w3m-search" "Search QUERY using SEARCH-ENGINE." t)
  (autoload 'w3m-weather "w3m-weather" "Display weather report." t)
  (autoload 'w3m-antenna "w3m-antenna" "Report chenge of WEB sites." t)
  (setq browse-url-browser-function 'w3m-browse-url)
  (setq w3m-use-cookies t)
  (setq w3m-default-display-inline-images t)
  (setq w3m-coding-system 'utf-8
	w3m-file-coding-system 'utf-8
	w3m-file-name-coding-system 'utf-8
	w3m-input-coding-system 'utf-8
	w3m-output-coding-system 'utf-8
	w3m-terminal-coding-system 'utf-8))

;; wanderlust
(use-package wandrlust
  :disabled
  :defer t
  :config
  (autoload 'wl "wl" "Wanderlust" t)
  (autoload 'wl-other-frame "wl" "Wanderlust on new frame." t)
  (autoload 'wl-draft "wl-draft" "Write draft with Wanderlust." t)
  (autoload 'wl-user-agent-compose "wl-draft" "Compose with Wanderlust." t)

  ;; inline image
  (setq mime-w3m-safe-url-regexp nil
	mime-w3m-display-inline-images t)
  (setq mime-edit-split-message nil)

  ;; directory
  (setq elmo-msgdb-directory (concat user-dir ".elmo/")
	elmo-cache-directory (concat elmo-msgdb-directory "cache/")
	wl-temporary-file-directory (concat elmo-msgdb-directory "tmp/")
	wl-folders-file (concat user-dir ".folders"))

  ;; user information
  (setq wl-from "user <user@gmail.com>")

  ;; local maildir
  (setq maildir-path (concat home-dir "Mail/")
	elmo-maildir-folder-path maildir-path
	elmo-localdir-folder-path maildir-path
	elmo-search-namazu-default-index-path maildir-path
	elmo-archive-folder-path maildir-path)

  ;; imap
  (setq elmo-imap4-default-server "imap.gmail.com"
	elmo-imap4-default-port 993
	elmo-imap4-default-stream-type 'ssl
	elmo-imap4-default-user "user"
	elmo-imap4-default-authenticate-type 'clear
	elmo-imap4-use-modified-utf7 t)

  ;; pop3
  (setq elmo-pop3-default-server "pop.gmail.com"
	elmo-pop3-default-port 995
	elmo-pop3-default-stream-type 'ssl
	elmo-pop3-default-user "user")

  ;; default folder
  (setq wl-default-folder "%Inbox"
	wl-fcc "%[Gmail]/Sent Mail"
	wl-draft-folder "%[Gmail]/Drafts"
	wl-trash-folder "%[Gmail]/Trash"
	wl-quicksearch-folder "%[Gmail]/All Mail"
	wl-spam-folder ".Spam"
	wl-queue-folder ".Queue"
	wl-fcc-force-as-read t
	wl-default-spec "%")
  (setq wl-folder-check-async t)

  ;; prefetch
  (setq wl-summary-incorporate-marks '("N" "U" "!" "A" "F" "$")
	wl-prefetch-threshold nil)

  ;; smtp
  (setq wl-smtp-posting-server "smtp.gmail.com"
	wl-smtp-posting-port 587
	wl-smtp-connection-type 'starttls
	wl-smtp-posting-user "user"
	wl-smtp-authenticate-type "plain"
	wl-local-domain "gmail.com"
	wl-message-id-domain "smtp.gmail.com")

  ;; summary
  (setq wl-auto-select-next 'unread
	wl-summary-auto-sync-marks nil
	wl-summary-width nil
	wl-summary-fix-timezone nil
	wl-summary-weekday-name-lang "en"
	wl-summary-showto-folder-regexp ".Sent.*"
	wl-summary-line-format "%T%P%Y-%M-%D(%W)%h:%m %[ %17f %]%[%1@%] %t%C%s"
	wl-message-mode-line-format (propertize "%f" 'face 'powerline-active1)
	wl-thread-insert-opened t
	wl-thread-open-reading-thread t)

  ;; message
  (setq wl-message-mode-line-format
	(propertize "%f/%n %F" 'face 'powerline-active1)
	wl-message-ignored-field-list '("^.*:")
	wl-message-visible-field-list
	'("^\\(To\\|Cc\\):"
	  "^Subject:"
	  "^\\(From\\|Reply-To\\):"
	  "^Organization:"
	  "^X-Attribution:"
	  "^\\(Posted\\|Date\\):"
	  "^User-Agent:"
	  )
	wl-message-sort-field-list
	'("^From"
	  "^Organization:"
	  "^X-Attribution:"
	  "^Subject"
	  "^Date"
	  "^To"
	  "^Cc")))

;; epa-file for encryption
(use-package epa-file
  :straight nil
  :config
  (epa-file-enable))

;; notmuch
(use-package notmuch
  :defer t
  :config
  (autoload 'notmuch "notmuch" "notmuch mail" t))

;; gnus
(use-package gnus
  :defer t
  :config
  ;; user
  (setq user-mail-address "user@gmail.com"
	user-full-name "user")

  ;; server
  (setq gnus-select-method '(nnnil ""))
  (setq gnus-secondary-select-methods
	'((nnimap "user@gmail.com"
		  (nnimap-address "imap.gmail.com")
		  (nnimap-server-port 993)
		  (nnimap-stream ssl)
		  (nnir-search-engine imap))
	  (nnmaildir "Archives"
		     (directory (concat home-dir "Mail/Local"))
		     (get-new-mail nil)
		     (nnir-search-engine notmuch))))

  (setq smtpmail-smtp-server "smtp.gmail.com"
	smtpmail-smtp-service 587
	send-mail-function 'smtpmail-send-it
	message-send-mail-function 'smtpmail-send-it)

  (require 'nnir)
  (setq nnir-notmuch-program "notmuch"
	nnir-notmuch-remove-prefix (concat home-dir "Mail/Local/"))

  (setq gnus-asynchronous t
	gnus-nntp-server nil
	gnus-fetch-old-headers t
	gnus-auto-select-first nil
	gnus-check-new-newsgroups nil
	gnus-check-bogus-newsgroups nil
	gnus-check-new-news nil
	gnus-read-active-file nil)

  (setq mm-text-html-renderer 'w3m
	mm-inline-text-html-with-images t
	mm-w3m-safe-url-regexp nil)

  ;; summary
  (setq gnus-parameters
	'((".*"
	   (display . all))))

  (setq-default gnus-summary-line-format "%U%R%z %(%-15,15f  %B%s%)\n"
		gnus-user-date-format-alist '((t . "%Y-%m-%d %H:%M"))
		gnus-summary-thread-gathering-function
		'gnus-gather-threads-by-references
		gnus-thread-sort-functions '(gnus-thread-sort-by-date)
		gnus-sum-thread-tree-false-root ""
		gnus-sum-thread-tree-indent " "
		gnus-sum-thread-tree-leaf-with-other "├► "
		gnus-sum-thread-tree-root ""
		gnus-sum-thread-tree-single-leaf "╰► "
		gnus-sum-thread-tree-vertical "│"))

;; mew
(use-package mew
  :disabled
  :defer t
  :config
  (autoload 'mew "mew" nil t)
  (autoload 'mew-send "mew" nil t)

  (add-to-list 'exec-path (concat user-dir "lisp/mew/bin/"))

  ;; read mail menu
  (setq read-mail-command 'mew)

  ;; sending a message command
  (autoload 'mew-user-agent-compose "mew" nil t)
  (if (boundp 'mail-user-agent)
      (setq mail-user-agent 'mew-user-agent))
  (if (fboundp 'define-mail-user-agent)
      (define-mail-user-agent
        'mew-user-agent
        'mew-user-agent-compose
        'mew-draft-send-message
        'mew-draft-kill
        'mew-send-hook))

  ;; icon
  (setq mew-icon-directory
	(expand-file-name "etc"
			  (file-name-directory (locate-library "mew.el"))))

  ;; network
  (setq mew-prog-ssl "/usr/bin/stunnel"
	mew-ssl-verify-level 0
	mew-use-cached-passwd t)

  ;; user
  (setq mew-name "user"
	mew-user "user")

  (setq mew-config-alist
	'(
	  (default
	    (mailbox-type imap)
	    (proto "%")
	    ;; imap
	    (imap-server "imap-mail.outlook.com")
	    (imap-ssl-port "993")
	    (imap-user "user")
	    (name "user")
	    (imap-ssl t)
	    (imap-auth t)
	    (imap-size 0)
	    (imap-delete t)
	    (imap-trash-folder "%Deleted")
	    ;; smtp
	    (smtp-server "smtp-mail.outlook.com")
	    (smtp-ssl-port "465")
	    (smtp-user "user")
	    (smtp-ssl t)
	    (smtp-auth t)
	    )))

  ;; encoding
  (setq mew-cs-database-for-encoding
	'(((ascii) nil "7bit" "7bit")
	  (nil utf-8 "base64" "B")))

  ;; html
  (require 'mew-w3m)
  (setq mew-mime-multipart-alternative-list '("Text/Html" "Text/Plain" ".*"))
  (setq mew-use-text/html t))
