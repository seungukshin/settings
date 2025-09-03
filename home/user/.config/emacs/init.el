;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; check statup time
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; startup time
(add-hook 'emacs-startup-hook
	  (lambda ()
	    (message "Emacs loaded in %s seconds with %d garbage collections."
		     (emacs-init-time) gcs-done)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; basic configure
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; directories
(setq home-dir (if (eq system-type 'windows-nt)
		   (expand-file-name
		    (concat (getenv "HOMEDRIVE") (getenv "HOMEPATH") "/"))
		 (expand-file-name "~/"))
      user-dir user-emacs-directory
      temp-dir (concat user-dir ".cache/")
      elpa-dir (concat user-dir "elpa/"))
(unless (file-exists-p temp-dir)
  (make-directory temp-dir t))

;; exec path
(add-to-list 'exec-path (concat home-dir "bin/"))
(setenv "PATH" (format "%s:%s" (concat home-dir "bin") (getenv "PATH")))
(cond ((eq system-type 'windows-nt)
       (add-to-list 'exec-path (concat (getenv "MSYS2") "/usr/bin"))
       (add-to-list 'exec-path (concat (getenv "MSYS2") "/mingw64/bin"))
       (add-to-list 'exec-path (concat (getenv "MSYS2") "/clangarm64/bin"))
       (add-to-list 'exec-path (concat (getenv "MSYS2") "/clangarm64/lib"))
       (setenv "PATH" (format "%s:%s:%s:%s:%s"
			      (concat (getenv "MSYS2") "/usr/bin")
			      (concat (getenv "MSYS2") "/mingw64/bin")
			      (concat (getenv "MSYS2") "/clangarm64/bin")
			      (concat (getenv "MSYS2") "/clangarm64/lib")
			      (getenv "PATH")))
       (setenv "LD_LIBRARY_PATH"
	       (format "%s:%s:%s"
		       (concat (getenv "MSYS2") "/clangarm64/bin")
		       (concat (getenv "MSYS2") "/clangarm64/lib")
		       (getenv "LD_LIBRARY_PATH")))
       (setenv "LIBRARY_PATH"
	       (format "%s:%s:%s"
		       (concat (getenv "MSYS2") "/clangarm64/bin")
		       (concat (getenv "MSYS2") "/clangarm64/lib")
		       (getenv "LIBRARY_PATH"))))
      ((eq system-type 'darwin)
       (add-to-list 'exec-path "/opt/homebrew/bin/")
       (setenv "PATH" (format "%s:%s" "/opt/homebrew/bin" (getenv "PATH")))
       (setenv "LIBRARY_PATH"
	       (format "%s:%s:%s"
		       "/opt/homebrew/opt/gcc/lib/gcc/current"
		       "/opt/homebrew/opt/libgccjit/lib/gcc/current"
		       "/opt/homebrew/opt/gcc/lib/gcc/current/gcc/aarch64-apple-darwin24/15")))
      (t
       (add-to-list 'exec-path "/var/run/host/bin")
       (setenv "PATH" (format "%s:%s"
			      "/var/run/host/bin"
			      (getenv "PATH")))
       (setenv "LD_LIBRARY_PATH" (format "%s:%s:%s:%s:%s:%s:%s"
					 (getenv "LD_LIBRARY_PATH")
					 "/usr/lib64"
					 "/usr/lib/x86_64-linux-gnu"
					 "/usr/lib/aarch64-linux-gnu"
					 "/usr/lib"
					 "/var/run/host/usr/lib/x86_64-linux-gnu"
					 "/var/run/host/usr/lib/aarch64-linux-gnu"))))

;; proxy
(when nil
  (setq url-proxy-services
	'(("no_proxy" . "^\\(localhost\\|192\\.168\\..*\\)")
	  ("http" . "proxy.com:8080")
	  ("https" . "proxy.com:8080"))))

;; paste
(global-set-key (kbd "C-c C-y") 'yank-from-kill-ring)

;; debug
(setq debug-on-error nil)
(if debug-on-error
    (setq use-package-verbose t
          use-package-expand-minimally nil
          use-package-compute-statistics t
          debug-on-error t)
  (setq use-package-verbose nil
        use-package-expand-minimally t))

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
;(setq use-package-compute-statistics t)

;; use package
(eval-when-compile
  (unless (require 'use-package nil t)
    (straight-use-package 'use-package)))

;; load path
(when nil
  (let ((default-directory (concat user-dir "lisp/")))
    (normal-top-level-add-to-load-path '("."))
    (normal-top-level-add-subdirs-to-load-path)))

;; benchmark
(use-package benchmark-init
  :disabled
  :ensure t
  :config
  (add-hook 'after-init-hook 'benchmark-init/deactivate))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; server
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; server
(use-package server
  :disabled
  :if (not (display-graphic-p))
  :config
  (server-mode 1)

  ;; use tcp server
;  (setq server-use-tcp t
;	server-host "ip")

  ;; start server
  (unless (server-running-p) (server-start)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; appearance
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; setup frame
(setq default-frame-alist '((tool-bar-lines . 0)
			    (menu-bar-lines . 0)
			    (vertical-scroll-bars)
			    (mouse-color . "blue")
			    (line-spacing . 0)
			    (left-fringe . 8)
			    (right-fringe . 13)
			    (internal-border-width . 10)
			    ;(fullscreen . maximized)
			    ;(background-color . "#000000")
			    (ns-appearance . dark)
			    (ns-transparent-titlebar . t)))

;; set transparency
(set-frame-parameter (selected-frame) 'alpha '(90 90))
(add-to-list 'default-frame-alist '(alpha 90 90))

;; menu
(when (eq system-type 'darwin)
  (menu-bar-mode t))
(when (display-graphic-p)
  (context-menu-mode))

;; buffer
(auto-image-file-mode t)			; display inline image
(setopt x-underline-at-descent-line nil		; pretty underlines
	switch-to-buffer-obey-display-actions t	; make switching buffers more consistent
	show-trailing-whitespace t		; underline trailing spaces
	indicate-buffer-boundaries 'left	; show buffer top and bottom in the margin
	inhibit-splash-screen t			; turn off the welcome screen
	sentence-end-double-space nil
	truncate-lines t)			; turn off word wrap

(setq inhibit-startup-message t			; disable startup message
      display-time-default-load-average nil)

(global-auto-revert-mode t)			; auto refresh
(setq auto-revert-avoid-polling t
      auto-revert-interval 5
      auto-revert-check-vc-info t)

(global-display-line-numbers-mode 1)		; line number
(setopt display-line-numbers-width 3)		; set a minimum width

;; fonts
(when (display-graphic-p)
  (set-fontset-font "fontset-default" 'latin
 		    (font-spec :name "Inconsolata Nerd Font" :size 16 :height 16))
  (set-fontset-font "fontset-default" 'han
 		    (font-spec :name "Noto Sans Mono CJK JP" :size 12 :height 12))
  (set-fontset-font "fontset-default" 'kana
 		    (font-spec :name "Noto Sans Mono CJK JP" :size 12 :height 12))
  (set-fontset-font "fontset-default" 'hangul
 		    (font-spec :name "D2CodingLigature Nerd Font" :size 12 :height 12))
  (set-frame-font "fontset-default" nil t))

;; theme
(use-package monokai-theme
  :ensure t
  :config
  (load-theme 'monokai t)
  ;; set transparency
  (unless (display-graphic-p)
    (set-face-background 'default "unspecified-bg" nil)))

(use-package doom-themes
  :disabled
  :ensure t
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-monokai-pro t)

  (doom-themes-visual-bell-config)		; enable flashing mode-line on errors
  (doom-themes-org-config))			; org-mode's native fontification.

;; mode line
(use-package doom-modeline
  :ensure t
  :init
  (doom-modeline-mode 1)
  :custom
  (doom-modeline-time nil)
  (doom-modeline-time-icon nil)
  (doom-modeline-time-live-icon nil)
  (doom-modeline-time-analogue-clock nil)
  (doom-modeline-enable-word-count nil)
  (doom-modeline-height 16))

(setq line-number-mode t			; display line number in mode line
      column-number-mode t			; display column number in mode line
      size-indication-mode t			; display file size in mode line
      display-time-day-and-date nil)		; hide time and date in mode line
;      display-time-format "%F %a %H:%M"		; display time in mode line
;      display-time-interval 60)
;(display-time-mode)

;; goggles
(use-package goggles
  :hook ((prog-mode text-mode) . goggles-mode)
  :config
  (setq goggles-pulse t))

;; scroll
(pixel-scroll-precision-mode)			; smooth scrolling
(setq pixel-resolution-fine-flag t		; scroll by number of pixels instead of lines
      mouse-wheel-scroll-amount '(1)		; pixel-resolution to scroll each mouse wheel event
      mouse-wheel-progressive-speed t)		; accelerate scrolling
(setopt mouse-wheel-tilt-scroll t
	mouse-wheel-flip-direction t)
(blink-cursor-mode -1)				; Steady cursor

;; tab bar
(use-package tab-bar
  :straight (:type built-in)
  :custom-face
  (tab-bar ((t (:inherit mode-line
			 :foreground "#75715e" :background "#272822"))))
  (tab-bar-tab ((t (:inherit mode-line :box (:color "#75715e")))))
  (tab-bar-tab-inactive ((t (:inherit mode-line-inactive
				      :background "#000000"))))
  :config
  (setq tab-bar-show t				; show tab bar always
	tab-bar-new-tab-choice "*dashboard*"	; buffer to show in new tabs
	tab-bar-tab-name-format-function	; tab style
	#'(lambda (tab i)
	    (let* ((current-p (eq (car tab) 'current-tab))
		   (name (alist-get 'name tab))
		   (buffer (get-buffer name))
		   (title (format " %d%s %-16s" i
				  (if (buffer-modified-p buffer) "*" "")
				  name)))
	      (propertize
	       (concat title tab-bar-close-button)
	       'face (if current-p '(tab-bar-tab) '(tab-bar-tab-inactive)))))
	tab-bar-format '(tab-bar-format-tabs	; tab bar style
			 tab-bar-separator
			 tab-bar-format-align-right
			 (lambda ()
			   dired-rsync-modeline-status)))
  (tab-bar-mode 1)				; enable tab bar
  ;(cl-loop for i from 1 to 8 do
  ;	   (global-set-key
  ;	    (kbd (format "C-x t %d" i))
  ;	    (kbd (format "C-u %d M-x tab-select RET" i)))
  ;	   (global-set-key
  ;	    (kbd (format "C-c t %d" i))
  ;	    (kbd (format "C-u %d M-x tab-select RET" i))))
  :bind
  (("C-x t g" . tab-select)
   ("C-x t t" . tab-recent)))

;; column indicator
(setopt display-fill-column-indicator-column 80)
(global-display-fill-column-indicator-mode)

;; buffer split
(set-display-table-slot standard-display-table
			'vertical-border (make-glyph-code ?┃))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; language
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; default encoding
(set-language-environment "utf-8")
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-file-name-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(modify-coding-system-alist 'file "" 'utf-8-unix)
(set-selection-coding-system 'utf-8)
(setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING)
      select-active-regions nil)

;; locale
(setq system-time-locale "C")

;; input method
(setq default-input-method "korean-hangul")
(global-set-key [?\S- ] 'toggle-input-method)

;; default indent
(setq indent-tabs-mode t
      tab-width 8)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; session and auto save
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; session
(when (display-graphic-p)
  (desktop-save-mode 1)				; auto save session

  (recentf-mode t)				; save recent files
  (setq recentf-save-file (expand-file-name "recentf" temp-dir)
	recentf-auto-cleanup 'never))

;; auto save
(setq backup-inhibited t			; disable backaup
      auto-save-default nil			; disable auto save
      auto-save-list-file-prefix temp-dir)

;; last position
(save-place-mode t)				; save last position
(setq save-place-file (expand-file-name "places" temp-dir)
      save-place-forget-unreadable-files nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; alternative to helm (vertico + consult)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; vertical completion for minibuffer commands
(use-package vertico
  :defer t
  :init
  (vertico-mode)
  (setq vertico-cycle t))

;; help message for minibuffer commands
(use-package marginalia
  :defer t
  :config
  (marginalia-mode))

;; powerful completion style
(use-package orderless
  :defer t
  :config
  (setq completion-styles '(orderless)))

;; completion contents
(use-package consult
  :init
  ;; Tweak the register preview for `consult-register-load',
  ;; `consult-register-store' and the built-in commands.  This improves the
  ;; register formatting, adds thin separator lines, register sorting and hides
  ;; the window mode line.
  (advice-add #'register-preview :override #'consult-register-window)
  (setq register-preview-delay 0.5)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  :config
  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep consult-man
   consult-bookmark consult-recent-file consult-xref
   consult-source-bookmark consult-source-file-register
   consult-source-recent-file consult-source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any)
   :initial (thing-at-point 'symbol))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (keymap-set consult-narrow-map (concat consult-narrow-key " ?") #'consult-narrow-help)

  :hook (completion-list-mode . consult-preview-at-point-mode)

  :bind
  (;; C-c bindings in `mode-specific-map'
   ("C-c M-x" . consult-mode-command)
   ("C-c h"   . consult-history)
   ("C-c k"   . consult-kmacro)
   ("C-c n"   . consult-man)
   ("C-c i"   . consult-info)
   ([remap Info-search] . consult-info)
   ;; C-x bindings in `ctl-x-map'
   ("C-x M-:" . consult-complex-command)	; repeat-complex-command
   ("C-x b"   . consult-buffer)			; switch-to-buffer
   ("C-x 4 b" . consult-buffer-other-window)	; switch-to-buffer-other-window
   ("C-x 5 b" . consult-buffer-other-frame)	; switch-to-buffer-other-frame
   ("C-x t b" . consult-buffer-other-tab)	; switch-to-buffer-other-tab
   ("C-x r b" . consult-bookmark)		; bookmark-jump
   ("C-x p b" . consult-project-buffer)		; project-switch-to-buffer
   ;; Custom M-# bindings for fast register access
   ("M-#"     . consult-register-load)
   ("M-'"     . consult-register-store)		; abbrev-prefix-mark (unrelated)
   ("C-M-#"   . consult-register)
   ;; Other custom bindings
   ("M-y"     . consult-yank-pop)		; yank-pop
   ;; M-g bindings in `goto-map'
   ("M-g e"   . consult-compile-error)
   ("M-g f"   . consult-flymake)		; or consult-flycheck
   ("M-g g"   . consult-goto-line)		; goto-line
   ("M-g M-g" . consult-goto-line)		; goto-line
   ("M-g o"   . consult-outline)		; or consult-org-heading
   ("M-g m"   . consult-mark)
   ("M-g k"   . consult-global-mark)
   ("M-g i"   . consult-imenu)
   ("M-g I"   . consult-imenu-multi)
   ;; M-s bindings in `search-map'
   ("C-c f f" . consult-find)
   ("C-c f d" . consult-fd)
   ("C-c f c" . consult-locate)
   ("C-c g g" . consult-grep)
   ("C-c g G" . consult-git-grep)
   ("C-c g r" . consult-ripgrep)
   ("C-c g l" . consult-line)
   ("C-c g L" . consult-line-multi)
   ("C-c g k" . consult-keep-lines)
   ("C-c g u" . consult-focus-lines)
   ;; Isearch integration
   ("M-s e"   . consult-isearch-history)
   :map isearch-mode-map
   ("M-e"     . consult-isearch-history)	; isearch-edit-string
   ("M-s e"   . consult-isearch-history)	; isearch-edit-string
   ("M-s l"   . consult-line)			; needed by consult-line to detect isearch
   ("M-s L"   . consult-line-multi)		; needed by consult-line to detect isearch
   ;; Minibuffer history
   :map minibuffer-local-map
   ("M-s"     . consult-history)		; next-matching-history-element
   ("M-r"     . consult-history)))		; previous-matching-history-element

(use-package embark
  :ensure t
  :init
  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)

  ;; Show the Embark target at point via Eldoc. You may adjust the
  ;; Eldoc strategy, if you want to see the documentation from
  ;; multiple providers. Beware that using this can be a little
  ;; jarring since the message shown in the minibuffer can be more
  ;; than one line, causing the modeline to move up and down:

  ;; (add-hook 'eldoc-documentation-functions #'embark-eldoc-first-target)
  ;; (setq eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)

  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none))))

  :bind
  (("C-."   . embark-act)			; pick some comfortable binding
   ("C-;"   . embark-dwim)			; good alternative: M-.
   ("C-h B" . embark-bindings)))		; alternative for `describe-bindings'

;; Consult users will also want the embark-consult package.
(use-package embark-consult
  :ensure t ; only need to install it, embark loads it after consult if found
  :hook (embark-collect-mode . consult-preview-at-point-mode))

(use-package consult-dir
  :bind
  (("C-x C-d" . consult-dir)
   :map minibuffer-local-completion-map
   ("C-x C-d" . consult-dir)
   ("C-x C-j" . consult-dir-jump-file)))

(use-package consult-cscope
  :straight (consult-cscope
	     :host github
	     :repo "seungukshin/consult-cscope")
  :hook (c-mode-common . consult-cscope-mode)
  :bind
  (:map c-mode-base-map
	("C-c c s" . consult-cscope-symbol)
	("C-c c g" . consult-cscope-definition)
	("C-c c d" . consult-cscope-calledby)
	("C-c c c" . consult-cscope-calling)
	("C-c c t" . consult-cscope-text)
	("C-c c e" . consult-cscope-egrep)
	("C-c c f" . consult-cscope-file)
	("C-c c i" . consult-cscope-including)
	("C-c c o" . consult-cscope-pop)))

;; popup completion-at-point
(use-package corfu
  :defer t
  :init
  (global-corfu-mode)
  :bind
  (:map corfu-map
   ("SPC" . corfu-insert-separator)
   ("C-n" . corfu-next)
   ("C-p" . corfu-previous)))

;; make corfu popup come up in terminal overlay
(use-package corfu-terminal
  :if (not (display-graphic-p))
  :defer t
  :config
  (corfu-terminal-mode))

;; fancy completion-at-point functions
(use-package cape
  :defer t
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file))

;; pretty icons for corfu
(use-package kind-icon
  :if (display-graphic-p)
  :defer t
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; helm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; helm
(use-package helm
  :disabled
  :ensure t
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
	helm-ff-file-name-history-use-recentf t
	helm-autoresize-max-height 0
	helm-autoresize-min-height 20)

  (global-unset-key (kbd "C-x c"))

  (defun s/project-root ()
    "return version managed root directory"
    (cl-loop for dir in '(".git/" ".hg/" ".svn/" ".git")
	     when (locate-dominating-file default-directory dir)
	     return it))

  (defun s/helm-fd-project-root ()
    "find files on the project root"
    (interactive)
    (require 'helm-fd)
    (let ((rootdir (s/project-root)))
      (unless rootdir
	(error "Could not find the project root. Create a git, hg or svn repository there first"))
      (helm-fd-1 rootdir)))

  (defun s/helm-fd-directory ()
    "find files on the selected directory"
    (interactive)
    (require 'helm-fd)
    (let ((directory
	   (file-name-as-directory
	    (read-directory-name "DefaultDirectory: "))))
      (helm-fd-1 directory)))

  (defun s/helm-fd-current-directory ()
    "find files on the current directory"
    (interactive)
    (require 'helm-fd)
    (helm-fd-1 default-directory))

  :bind
  (("C-c h"   . helm-command-prefix)
   ("C-h"     . helm-command-prefix)
   ("M-x"     . helm-M-x)
   ("M-y"     . helm-show-kill-ring)
   ("C-x b"   . helm-mini)
   ("C-x C-f" . helm-find-files)
   ("C-c e"   . helm-resume)
   ("C-c f a"  . s/helm-fd-project-root)
   ("C-c f d"  . s/helm-fd-directory)
   ("C-c f c"  . s/helm-fd-current-directory)
   :map helm-map
   ("<tab>"   . helm-execute-persistent-action)
   ("C-i"     . helm-execute-persistent-action)
   ("C-z"     . helm-select-action)))

;; helm-ag
(use-package helm-ag
  :disabled
  :defer t
  :config
  (setq helm-ag-base-command "rg --vimgrep --no-heading --smart-case")
  (setq helm-ag-insert-at-point 'symbol)
  :bind
  (("C-c r a" . helm-do-ag-project-root)
   ("C-c r d" . helm-do-ag)
   ("C-c r f" . helm-do-ag-this-file)
   ("C-c r b" . helm-do-ag-buffers)
   ("C-c r o" . helm-ag-pop-stack)))

;; fzf
(use-package fzf
  :defer t
  :config
  (setq fzf/args "-x --color bw --print-query --margin=1,0 --no-hscroll"
        fzf/executable "fzf"
        fzf/git-grep-args "-i --line-number %s"
        fzf/grep-command "rg --no-heading -nH"
        fzf/position-bottom t
        fzf/window-height 15)
  :bind
  ;; Don't forget to set keybinds!
  )

;; helm-swoop
(use-package helm-swoop
  :disabled
  :defer t
  :config
  (setq helm-multi-swoop-edit-save t
        helm-swoop-split-with-multiple-windows nil
        helm-swoop-split-direction 'split-window-horizontally
        helm-swoop-speed-or-color t
        helm-swoop-move-to-line-cycle t
        helm-swoop-use-line-number-face t
        helm-swoop-use-fuzzy-match t)
  :bind
  (("C-c s s" . helm-swoop)
   ("C-c s r" . helm-swoop-back-to-last-point)
   ("C-c s m" . helm-multi-swoop)
   ("C-c s a" . helm-multi-swoop-all))
  (:map isearch-mode-map
   ("C-i" . helm-swoop-from-isearch))
  (:map helm-swoop-map
   ("C-s" . helm-next-line)
   ("C-r" . helm-previous-line)
   ("C-m" . helm-multi-swoop-current-mode-from-helm-swoop)
   ("C-a" . helm-multi-swoop-all-from-helm-swoop))
  (:map helm-multi-swoop-map
   ("C-s" . helm-next-line)
   ("C-r" . helm-previous-line)))

;; helm-google
(use-package helm-google
  :disabled
  :defer t
  :bind ("C-c w" . helm-google))

;; xcscope
(use-package xcscope
  :disabled
  :defer t)

;; helm-cscope
(use-package helm-cscope
  :disabled
  :defer t
  :init
  (add-hook 'c-mode-common-hook 'helm-cscope-mode)
  :config
  ;; disable auto database update
  (setq cscope-option-do-not-update-database t)
  :bind
  (:map c-mode-base-map
   ("C-c c s" . helm-cscope-find-this-symbol)
   ("C-c c g" . helm-cscope-find-global-definition)
   ("C-c c d" . helm-cscope-find-called-this-function)
   ("C-c c c" . helm-cscope-find-calling-this-function)
   ("C-c c t" . helm-cscope-find-this-text-string)
   ("C-c c e" . helm-cscope-find-egrep-pattern)
   ("C-c c f" . helm-cscope-find-this-file)
   ("C-c c i" . helm-cscope-find-files-including-file)
   ("C-c c o" . helm-cscope-pop-mark)))

;; global
(use-package helm-gtags
  :disabled
  :defer t
  :init
  (add-hook 'c-mode-common-hook 'helm-gtags-mode)
  (add-hook 'java-mode-hook 'helm-gtags-mode)
  (add-hook 'ruby-mode-hook 'helm-gtags-mode)
  (add-hook 'js-mode-hook 'helm-gtags-mode)
  (add-hook 'typescript-mode-hook 'helm-gtags-mode)
  :config
  (custom-set-variables
   '(helm-gtags-ignore-case t)
   '(helm-gtags-display-style 'detail))
  :bind
  (:map c-mode-base-map
   ("C-c g s" . helm-gtags-find-symbol)
   ("C-c g g" . helm-gtags-find-tag)
   ("C-c g r" . helm-gtags-find-rtag)
   ("C-c g p" . helm-gtags-find-pattern)
   ("C-c g f" . helm-gtags-find-files)
   ("C-c g o" . helm-gtags-pop-stack)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; mini buffer and completion
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defalias 'yes-or-no-p 'y-or-n-p)		; yes/no to y/n
(savehist-mode)					; save history of minibuffer
(setopt enable-recursive-minibuffers t		; keep using the minibuffer
	completion-cycle-threshold 1		; cycles candidates with tab
	completions-detailed t			; show annotations
	tab-always-indent 'complete		; tab tries to complete first,
						; otherwise indent
	completion-styles '(basic initials substring)
	completion-auto-help 'always		; open completion always
	completions-max-height 20
	completions-detailed t
	completions-format 'one-column
	completions-group t
	completion-auto-select 'second-tab
	completion-auto-select t)

(keymap-set minibuffer-mode-map "TAB" 'minibuffer-complete)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; development
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; major mode
(use-package emacs
  :straight (:type built-in)
  :init
  ;; use treesitter enabled mode than normal mode
  (setq major-mode-remap-alist
        '((python-mode . python-ts-mode)
	  (bash-mode . bash-ts-mode)
	  (js2-mode . js-ts-mode)
	  ;(typescript-mode . typescript-ts-mode)
	  (typescript-mode . tsx-mode)
	  (css-mode . css-ts-mode)
	  (json-mode . json-ts-mode)
	  (dockerfile-mode . dockerfile-ts-mode)
	  (yaml-mode . yaml-ts-mode)
	  (toml-mode . toml-ts-mode)))
  (add-to-list 'auto-mode-alist '("CMakeLists.txt" . cmake-ts-mode))
  :hook
  ;; Auto parenthesis matching
  (prog-mode . electric-pair-mode))

(use-package cc-mode
  :straight (:type built-in)
  :defer t
  :custom
  (indent-tabs-mode t)
  (tab-width 8)
  (c-basic-offset 8))

(use-package sh-mode
  :straight (:type built-in)
  :defer t
  :custom
  (indent-tabs-mode t)
  (tab-width 8)
  (sh-basic-offset 8))

(use-package rust-mode
  :defer t)

(use-package go-mode
  :defer t)

(use-package tree-sitter
  :defer t)

(use-package coverlay
  :straight (coverlay
	     :type git
	     :host github
	     :repo "twada/coverlay.el")
  :defer t)

(use-package css-in-js-mode
  :straight (css-in-js-mode
	     :type git
	     :host github
	     :repo "orzechowskid/tree-sitter-css-in-js")
  :defer t)

(use-package origami
  :straight (origami
	     :type git
	     :host github
	     :repo "gregsexton/origami.el")
  :defer t)

;(use-package typescript-ts-mode
;  :straight (:type built-in)
;  :defer t
;  :mode "\\.tsx?\\'")

(use-package tsx-mode
  :straight (tsx-mode
	     :type git
	     :host github
	     :repo "orzechowskid/tsx-mode.el")
  :requires (coverlay css-in-js-mode origami)
  :defer t)

(use-package lua-mode
  :defer t
  :config
  (setq lua-indent-level 2))

(use-package ahk-mode
  :straight (ahk-mode
	     :type git
	     :host github
	     :repo "punassuming/ahk-mode")
  :defer t)

(use-package dockerfile-ts-mode
  :straight (:type built-in)
  :defer t
  :mode (("\\Dockerfile\\'" . dockerfile-ts-mode)
	 ("\\.dockerignore\\'" . dockerfile-ts-mode)))

(use-package yaml-ts-mode
  :straight (:type built-in)
  :mode "\\.ya?ml\\'"
  :defer t)

(use-package toml-ts-mode
  :straight (:type built-in)
  :mode "\\.toml\\'"
  :defer t)

(use-package markdown-mode
  :defer t)

;; indent guide
(use-package highlight-indent-guides
  :defer t
  :config
  (setq highlight-indent-guides-method 'character)
  (set-face-background 'highlight-indent-guides-odd-face "darkgray")
  (set-face-background 'highlight-indent-guides-even-face "dimgray")
  (set-face-foreground 'highlight-indent-guides-character-face "dimgray")
  :hook
  (prog-mode . highlight-indent-guides-mode))

;; folding
(use-package hideshow
  :defer t
  :hook
  ((prog-mode . hs-minor-mode)
   (org-mode . hs-minor-mode))
  :bind
  (("<C-tab>"     . hs-toggle-hiding)
   ("<backtab>"   . hs-hide-all)
   ("<C-backtab>" . hs-show-all)))

;; highlight
(use-package highlight-thing
  :defer t
  :config
  (setq highlight-thing-what-thing 'symbol)
  :hook
  (prog-mode . highlight-thing-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; lsp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; eglot
;; https://www.masteringemacs.org/article/seamlessly-merge-multiple-documentation-sources-eldoc
(use-package eglot
  :disabled
  :hook
  (((python-mode ruby-mode elixir-mode lua-mode) . eglot-ensure))
  :custom
  (eglot-send-changes-idle-time 0.1)
  (eglot-extend-to-xref t)			; activate Eglot in referenced non-project files

  :config
  (fset #'jsonrpc--log-event #'ignore)		; don't log every event

  ;; lua-language-server
  (add-to-list 'exec-path (concat user-dir "language-server/lua-language-server/bin/"))
  (add-to-list 'eglot-server-programs '(lua-mode . ("lua-language-server")))

  ;(add-to-list 'eglot-server-programs
               ;'(haskell-mode . ("haskell-language-server-wrapper" "--lsp")))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; version control system
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; magit
(use-package magit
  :defer t
  :config
  (setq transient-default-level 5
	magit-auto-revert-mode nil
        magit-diff-refine-hunk t ; show granular diffs in selected hunk
        ;; Don't autosave repo buffers. This is too magical, and saving can
        ;; trigger a bunch of unwanted side-effects, like save hooks and
        ;; formatters. Trust the user to know what they're doing.
        magit-save-repository-buffers nil
        ;; Don't display parent/related refs in commit buffers; they are rarely
        ;; helpful and only add to runtime costs.
        magit-revision-insert-related-refs nil)
  :bind
  (("C-x g s" . magit-status)
   ("C-x g l" . magit-log-all)))

;; git-gutter
(use-package git-gutter
  :ensure t
  :config (global-git-gutter-mode t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; org
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(when (display-graphic-p)
  (use-package org
    :defer t
    :straight (:type built-in)
    :hook ((org-mode . flyspell-mode)		; spell checking
	   (org-mode . iscroll-mode))
    :custom-face
    ;; heading font size
    (org-level-1 ((t (:height 1.0))))
    (org-level-2 ((t (:height 1.0))))
    (org-level-3 ((t (:height 1.0))))
    (org-level-4 ((t (:height 1.0))))
    (org-level-5 ((t (:height 1.0))))
    (org-level-6 ((t (:height 1.0))))
    :config
    ;; agenda
    (setq org-directory (concat home-dir "org/pages/")
	  org-agenda-dir (concat home-dir "org/pages/")
	  org-agenda-files (directory-files-recursively org-agenda-dir "\\.org$")
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

    (setq org-capture-templates
          '(("c" "Default Capture" entry (file "inbox.org")
             "* TODO %?\n%U\n%i")
            ;; Capture and keep an org-link to the thing we're currently working with
            ("r" "Capture with Reference" entry (file "inbox.org")
             "* TODO %?\n%U\n%i\n%a")
            ;; Define a section
            ("w" "Work")
            ("wm" "Work meeting" entry (file+headline "work.org" "Meetings")
             "** TODO %?\n%U\n%i\n%a")
            ("wr" "Work report" entry (file+headline "work.org" "Reports")
             "** TODO %?\n%U\n%i\n%a")))

    (setq org-agenda-custom-commands
          '(("n" "Agenda and All Todos"
             ((agenda)
              (todo "TODO" ((org-agenda-skip-function '(org-agenda-skip-entry-if 'scheduled 'deadline 'timestamp))))))
            ("w" "Work" agenda ""
             ((org-agenda-files '("work.org"))))))

    ;; tags
    (setq org-tag-alist '(
			  ;; locale
			  (:startgroup)
			  ("home" . ?h)
			  ("work" . ?w)
			  ("school" . ?s)
			  (:endgroup)
			  (:newline)
			  ;; scale
			  (:startgroup)
			  ("one-shot" . ?o)
			  ("project" . ?j)
			  ("tiny" . ?t)
			  (:endgroup)
			  ;; misc
			  ("meta")
			  ("review")
			  ("reading")))

    ;; todo keyword
    (setq org-todo-keywords '((sequence "TODO(t)" "WAIT(w)" "|" "DONE(d)" "DROP(p)"))
	  org-hide-leading-stars t
	  org-startup-indented t
	  org-startup-folded t)

    ;; disable code block indentation
    (setq org-src-preserve-indentation nil
	  org-edit-src-content-indentation 0)

    ;; apps to open file
    (setq org-file-apps
	  '(("\\.docx?\\'" . default)
	    ("\\.xlsx?\\'" . default)
	    ("\\.pptx?\\'" . default)
	    ("\\.mkv\\'" . "mpv %s")
	    ("\\.mp4\\'" . "mpv %s")
	    (auto-mode . emacs)))

    ;; store visibility
    (add-hook 'org-cycle-hook
	      (lambda (symbol-state)
		(interactive)
		;; state:      folded, children, subtree
		;; visibility: folded, children, content, all
		(let* ((level (nth 0 (org-heading-components)))
		       (state (symbol-name symbol-state))
		       (visibility (if (string= state "subtree") "all" state)))
		  (if (string= state "folded")
		      (org-entry-delete nil "visibility")
		    (org-entry-put nil "visibility" state))
;		  (org-map-entries
;		   (lambda ()
;		     (let* ((level (nth 0 (org-heading-components)))
;			    (match (format "LEVEL=%d" (+ level 1)))
;			    (subtree (length (org-map-entries t match 'tree)))
;			    (current (org-entry-get nil "visibility")))
;		       (if (and (> subtree 0) current)
;			   (org-entry-put nil "visibility" visibility))))
;		   (format "LEVEL=%d" (+ level 1)) 'tree)
		  )))

    ;; babel
    (org-babel-do-load-languages
     'org-babel-load-languages
     '((dot . t)
       (python . t)))

    (when (eq system-type 'darwin)
      (setq org-babel-python-command "/opt/homebrew/bin/python3"
	    python-remove-cwd-from-path nil))

    ;; display inline image
    (setq org-display-inline-images t
	  org-display-remote-inline-images t
	  org-redisplay-inline-images t
	  org-startup-with-inline-images t
	  org-image-actual-width 800)

    (defun org-image-resize (frame)
      (when (derived-mode-p 'org-mode)
	(setq org-image-actual-width (/ (window-pixel-width) 2))
	(org-redisplay-inline-images)))
    (add-hook 'window-size-change-functions 'org-image-resize)
    (add-hook 'org-babel-after-execute-hook 'org-redisplay-inline-images)

    ;; use the same window for follwing file link
    (setf (cdr (assoc 'file org-link-frame-setup)) 'find-file)

    ;; export
    (add-to-list 'org-export-backends 'md)
    (setq org-export-with-smart-quotes t)

    ;; refile configuration
    (setq org-outline-path-complete-in-steps nil
	  org-refile-use-outline-path 'file)

    ;; citation
    (require 'oc-csl)

    ;; use [[duckduckgo:OrgMode][org mode]]
    ;; instead of [[https://duckduckgo.com/?q=OrgMode][org mode]]
    (setq org-link-abbrev-alist
	  '(("Nu Html Checker" . "https://validator.w3.org/nu/?doc=%h")
            ("duckduckgo"      . "https://duckduckgo.com/?q=%s")))

    :bind
    (:map global-map
     ("C-c a" . org-agenda)
     ("C-c o s" . org-store-link)		; Mnemonic: link → store
     ("C-c o i" . org-insert-link-global)))	; Mnemonic: link → insert

  (use-package org-roam
    :defer t
    :after org
    :init
    (setq org-roam-directory "~/org/"
	  org-roam-index-file "~/org/index.org")

    :config
    (org-roam-db-autosync-mode)
    ;; Dedicated side window for backlinks
    (add-to-list 'display-buffer-alist
		 '("\\*org-roam\\*"
                   (display-buffer-in-side-window)
                   (side . right)
                   (window-width . 0.4)
                   (window-height . fit-window-to-buffer))))

  (use-package iscroll
    :defer t
    :after org)

  (use-package org-yt
    :straight (org-yt
	       :type git
	       :host github
	       :repo "TobiasZawada/org-yt")
    :after org)

  (use-package org-remoteimg
    :straight (org-remoteimg
	       :type git
	       :host github
	       :repo "gaoDean/org-remoteimg")
    :after (org org-yt)
    :config
    (setq url-cache-directory temp-dir
	  url-automatic-caching t
	  org-display-remote-inline-images 'cache))

  (use-package org-imgtog
    :straight (org-imgtog
	       :type git
	       :host github
	       :repo "gaoDean/org-imgtog")
    :defer t
    :after org
    :hook org-mode)

  (use-package org-transclusion
    :defer t
    :after org
    :bind
    (("C-c o a"  . org-transclusion-add)
     ("C-c o m"  . org-transclusion-transient-menu)
     (:map org-transclusion-map
      ("C-c o A" . org-transclusion-add-all)
      ("C-c o r" . org-transclusion-remove)
      ("C-c o R" . org-transclusion-remove-all)
      ("C-c o T" . org-transclusion-activate)
      ("C-c o D" . org-transclusion-deactivate)
      ("C-c o d" . org-transclusion-detach))))

  (use-package svg-tag-mode
    :hook (org-mode . svg-tag-mode)
    :config
    (defconst date-re "[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}")
    (defconst time-re "[0-9]\\{2\\}:[0-9]\\{2\\}")
    (defconst day-re "[A-Za-z]\\{3\\}")
    (defconst day-time-re (format "\\(%s\\)? ?\\(%s\\)?" day-re time-re))

    (defun svg-progress-percent (value)
      (save-match-data
	(svg-image (svg-lib-concat
		    (svg-lib-progress-bar  (/ (string-to-number value) 100.0)
					   nil :margin 0 :stroke 2 :radius 3 :padding 2 :width 11)
		    (svg-lib-tag (concat value "%")
				 nil :stroke 0 :margin 0)) :ascent 'center)))

    (defun svg-progress-count (value)
      (save-match-data
	(let* ((seq (split-string value "/"))
               (count (if (stringp (car seq))
			  (float (string-to-number (car seq)))
			0))
               (total (if (stringp (cadr seq))
			  (float (string-to-number (cadr seq)))
			1000)))
	  (svg-image (svg-lib-concat
                      (svg-lib-progress-bar (/ count total) nil
                                            :margin 0 :stroke 2 :radius 3 :padding 2 :width 11)
                      (svg-lib-tag value nil
				   :stroke 0 :margin 0)) :ascent 'center))))

    (setq svg-tag-tags
	  `(
            ;; todo / done
            ("TODO" . ((lambda (tag) (svg-tag-make "TODO" :face 'org-todo :inverse t :margin 0))))
            ("WAIT" . ((lambda (tag) (svg-tag-make "WAIT" :face 'org-todo :inverse t :margin 0))))
            ("DONE" . ((lambda (tag) (svg-tag-make "DONE" :face 'org-done :inverse t :margin 0))))
            ("DROP" . ((lambda (tag) (svg-tag-make "DROP" :face 'org-done :inverse t :margin 0))))
            ;; tags
            (":\\([A-Za-z0-9]+\\)" . ((lambda (tag) (svg-tag-make tag))))
            (":\\([A-Za-z0-9]+[ \-]\\)" . ((lambda (tag) tag)))
            ;; priority
            ("\\[#[A-Z]\\]" . ( (lambda (tag)
				  (svg-tag-make tag :face 'org-priority
						:beg 2 :end -1 :margin 0))))
            ;; citation
            ("\\(\\[cite:@[A-Za-z]+:\\)" . ((lambda (tag)
                                              (svg-tag-make tag
                                                            :inverse t
                                                            :beg 7 :end -1
                                                            :crop-right t))))
            ("\\[cite:@[A-Za-z]+:\\([0-9]+\\]\\)" . ((lambda (tag)
                                                       (svg-tag-make tag
								     :end -1
								     :crop-left t))))
            ;; active date
            (,(format "\\(<%s>\\)" date-re) .
             ((lambda (tag)
		(svg-tag-make tag :beg 1 :end -1 :margin 0))))
            (,(format "\\(<%s \\)%s>" date-re day-time-re) .
             ((lambda (tag)
		(svg-tag-make tag :beg 1 :inverse nil :crop-right t :margin 0))))
            (,(format "<%s \\(%s>\\)" date-re day-time-re) .
             ((lambda (tag)
		(svg-tag-make tag :end -1 :inverse t :crop-left t :margin 0))))
            ;; inactive date
            (,(format "\\(\\[%s\\]\\)" date-re) .
             ((lambda (tag)
		(svg-tag-make tag :beg 1 :end -1 :margin 0 :face 'org-date))))
            (,(format "\\(\\[%s \\)%s\\]" date-re day-time-re) .
             ((lambda (tag)
		(svg-tag-make tag :beg 1 :inverse nil :crop-right t :margin 0 :face 'org-date))))
            (,(format "\\[%s \\(%s\\]\\)" date-re day-time-re) .
             ((lambda (tag)
		(svg-tag-make tag :end -1 :inverse t :crop-left t :margin 0 :face 'org-date))))
            ;; progress
            ("\\(\\[[0-9]\\{1,3\\}%\\]\\)" . ((lambda (tag)
						(svg-progress-percent (substring tag 1 -2)))))
            ("\\(\\[[0-9]+/[0-9]+\\]\\)" . ((lambda (tag)
                                              (svg-progress-count (substring tag 1 -1)))))
            ))

    ;; workaround to apply svg-tag on agenda
    (defun eli-org-agenda-show-svg ()
      (let* ((case-fold-search nil)
             (keywords (mapcar #'svg-tag--build-keywords svg-tag--active-tags))
             (keyword (car keywords)))
	(while keyword
          (save-excursion
            (while (re-search-forward (nth 0 keyword) nil t)
              (overlay-put (make-overlay
                            (match-beginning 0) (match-end 0))
                           'display  (nth 3 (eval (nth 2 keyword)))) ))
          (pop keywords)
          (setq keyword (car keywords)))))
    (add-hook 'org-agenda-finalize-hook #'eli-org-agenda-show-svg)
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; terminal
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun s/tmux (command &rest args)
  "Execute COMMAND in tmux"
  (let ((bin (executable-find "tmux")))
    (unless bin
      (error "Could not find tmux executable"))
    (let* ((args (mapcar #'shell-quote-argument (delq nil args)))
           (cmdstr (format "%s %s" bin (if args (apply #'format command args) command)))
           (output (get-buffer-create " *tmux stdout*"))
           (errors (get-buffer-create " *tmux stderr*"))
           code)
      (unwind-protect
          (if (= 0 (setq code (shell-command cmdstr output errors)))
              (with-current-buffer output
                (setq +tmux-last-command `(,(substring cmdstr (+ 1 (length bin))) ,@args))
                (buffer-string))
            (error "[%d] tmux $ %s (%s)"
                   code
                   (with-current-buffer errors
                     (buffer-string))
                   cmdstr))
        (and (kill-buffer output)
             (kill-buffer errors))))))

(defun s/tmux/run (command &optional noreturn)
  "Run COMMAND in tmux. If NORETURN is non-nil, send the commands as keypresses
but do not execute them."
  (interactive
   (list (read-string "tmux $ ")
         current-prefix-arg))
  (s/tmux (concat "send-keys C-u "
                 (shell-quote-argument command)
                 (unless noreturn " Enter"))))

(defun s/tmux-execute-current-line-or-region ()
  "execute text of current line or region in tmux"
  (interactive)
  (let* ((current-line (buffer-substring
                        (save-excursion
                          (beginning-of-line)
                          (point))
                        (save-excursion
                          (end-of-line)
                          (point))))
         (buf (current-buffer))
         (command (string-trim
               (if (use-region-p)
                   (buffer-substring (region-beginning) (region-end))
                 current-line))))
    (message command)
    (if (string-prefix-p "$ " command)
	(s/tmux (concat "send-keys C-u "
			(shell-quote-argument (replace-regexp-in-string "^$ " "" command))
			" Enter"))
      (s/tmux command))))
(global-set-key (kbd "C-c m") 's/tmux-execute-current-line-or-region)

(use-package vterm
  :defer t
  ;:ensure t
  :hook (vterm-mode . (lambda ()
			(display-line-numbers-mode 0)
			(setq-local show-trailing-whitespace nil)))
  :config
  (setq vterm-max-scrollback 100000)
  :bind
  (:map vterm-mode-map
	("C-c t" . vterm-copy-mode))
;  :hook (vterm-mode . (lambda ()
;			(set (make-local-variable 'buffer-face-mode-face)
;			     '(:family "Inconsolata Nerd Font" :size 16 :height 16))
;			'(add-text-properties '(line-spacing 0 line-height 1))
;			(buffer-face-mode t)
;			(setq-default line-spacing 0.0)
;			(setq line-spacing 0.0
;			      line-height 1.0)))
;  :config
;  (if (file-exists-p "/bin/zsh")
;      (setq vterm-shell "/bin/zsh")
;    (setq vterm-shell "/bin/bash"))
;  (defun s/vterm-execute-current-line-or-region ()
;    "Insert text of current line or region in vterm and execute."
;    (interactive)
;    (let* ((current-line (buffer-substring
;                          (save-excursion
;                            (beginning-of-line)
;                            (point))
;                          (save-excursion
;                            (end-of-line)
;                            (point))))
;           (buf (current-buffer))
;           (raw (string-trim
;                     (if (use-region-p)
;                         (buffer-substring (region-beginning) (region-end))
;                       current-line)))
;	   (command (replace-regexp-in-string "^$ " "" raw)))
;      (unless (get-buffer vterm-buffer-name)
;        (vterm))
;      (display-buffer vterm-buffer-name t)
;      (switch-to-buffer-other-window vterm-buffer-name)
;      (vterm--goto-line -1)
;      (vterm-send-string command t)
;      (vterm-send-return)
;      (switch-to-buffer-other-window buf)
;      (when (featurep 'beacon)
;        (beacon-blink))))
;  :bind (("C-c v" . s/vterm-execute-current-line-or-region))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; etc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; which-key: shows a popup of available keybindings when typing a long key
;; sequence (e.g. C-x ...)
(use-package which-key
  :ensure t
  :config
  (which-key-mode))

;; ediff
(setq ediff-window-setup-function 'ediff-setup-windows-plain
      ediff-split-window-function 'split-window-horizontally)

(use-package vdiff
  :defer t
  :config
  (define-key vdiff-mode-map (kbd "C-c") vdiff-mode-prefix-map))

(use-package nerd-icons
  :defer t)

(use-package ibuffer-vc
  :defer t
  :init
  (add-hook 'ibuffer-hook
	    (lambda ()
	      (ibuffer-vc-set-filter-groups-by-vc-root)
	      (unless (eq ibuffer-sorting-mode 'alphabetic)
		(ibuffer-do-srot-by-alphabetic))))
  :bind ("C-x C-b" . 'ibuffer))

(use-package dired-rsync
  :demand t
  :after dired
  :custom
  (dired-rsync-command
   (cond ((eq system-type 'darwin)
	  "/opt/homebrew/bin/rsync")
	 (t
	  "rsync")))
;  (dired-rsync-options
;   (cond ((eq system-type 'darwin)
;	  "-azh --progress")
;	 (t
;	  "-azh --info=progress2")))
  :bind
  (:map dired-mode-map
        ("r r" . dired-rsync)))

(use-package dired-rsync-transient
  :demand t
  :after dired
  :bind
  (:map dired-mode-map
        ("r t" . dired-rsync-transient)))

(use-package dired-open-with
  :ensure t)

(use-package dirvish
  :defer t
  :init
  (dirvish-override-dired-mode)
  :hook
  ((dired-mode . (lambda ()
		   (display-line-numbers-mode 0)))
   (dirvish-directory-view-mode . (lambda ()
				    (display-line-numbers-mode 0))))
  :custom
  (dirvish-quick-access-entries
   (cond ((eq system-type 'windows-nt)
	  (list (list "h" home-dir                      "Home")
		(list "o" (concat home-dir "org")       "org")
		(list "d" (concat home-dir "Downloads") "Downloads")
		(list "c" (concat home-dir "Documents") "Documents")
		(list "p" (concat home-dir "Pictures")  "Pictures")
		(list "m" (concat home-dir "Music")     "Music")
		(list "v" (concat home-dir "Videos")    "Videos")))
	 ((eq system-type 'darwin)
	  (list (list "h" home-dir                      "Home")
		(list "o" (concat home-dir "org")       "org")
		(list "d" (concat home-dir "Downloads") "Downloads")
		(list "c" (concat home-dir "Documents") "Documents")
		(list "p" (concat home-dir "Pictures")  "Pictures")
		(list "m" (concat home-dir "Music")     "Music")
		(list "v" (concat home-dir "Movies")    "Movies")))
	 (t
	  (list (list "h" home-dir                      "Home")
		(list "o" (concat home-dir "org")       "org")
		(list "d" (concat home-dir "Downloads") "Downloads")
		(list "c" (concat home-dir "Documents") "Documents")
		(list "p" (concat home-dir "Pictures")  "Pictures")
		(list "m" (concat home-dir "Music")     "Music")
		(list "v" (concat home-dir "Videos")    "Videos")))))
  :config
  ;; appearance
  (setq dirvish-header-line-height '(16 . 16)
	dirvish-header-line-format '(:left (path) :right (free-space))
	dirvish-mode-line-height '(16 . 16)
	dirvish-mode-line-format
	'(:left (sort file-time " " file-size symlink) :right (omit yank index))
	dirvish-attributes
	;'(nerd-icons collapse subtree-state vc-state git-msg file-size file-time))
	'(nerd-icons collapse subtree-state vc-state file-size file-time))

  ;; behavior
  (setq delete-by-moving-to-trash t
	dired-listing-switches
	"-l --almost-all --human-readable --group-directories-first --no-group")
  ;(dirvish-peek-mode)		; preview files in minibuffer
  ;(dirvish-side-follow-mode)	; similar to `treemacs-follow-mode'

  ;; use an external app
  (cond
   ((eq system-type 'windows-nt)
    (setq dirvish-default-app "start"
	  dirvish-external-apps
	  (list (list "docx" dirvish-default-app)
		(list "doc" dirvish-default-app)
		(list "xlsx" dirvish-default-app)
		(list "xls" dirvish-default-app)
		(list "pptx" dirvish-default-app)
		(list "ppt" dirvish-default-app)
		'("svg" "firefox")
		'("mkv" "mpv")
		'("mp4" "mpv"))))
   ((eq system-type 'darwin)
    ;; fix for Listing directory failed but ‘access-file’ worked
    (setq insert-directory-program "gls")
    (setq dirvish-default-app "open"
	  dirvish-external-apps
	  (list (list "docx" dirvish-default-app)
		(list "doc" dirvish-default-app)
		(list "xlsx" dirvish-default-app)
		(list "xls" dirvish-default-app)
		(list "pptx" dirvish-default-app)
		(list "ppt" dirvish-default-app)
		'("svg" "firefox")
		'("mkv" "mpv")
		'("mp4" "mpv"))))
   (t
    (setq dirvish-default-app "xdg-open"
	  dirvish-external-apps
	  (list (list "docx" dirvish-default-app)
		(list "doc" dirvish-default-app)
		(list "xlsx" dirvish-default-app)
		(list "xls" dirvish-default-app)
		(list "pptx" dirvish-default-app)
		(list "ppt" dirvish-default-app)
		'("svg" "firefox")
		'("mkv" "mpv")
		'("mp4" "mpv")))))
  (defun dirvish-open-binaries-externally (file fn)
    "When FN is not `dired', open binary FILE externally."
    (when-let* (((not (eq fn 'dired)))
		((file-exists-p file))
		((not (file-directory-p file)))
		(ext (downcase (or (file-name-extension file) "")))
		(pair (assoc ext dirvish-external-apps))
		(app (nth 1 pair)))
      ;; return t to terminate `dirvish--find-entry'.
      (if (string-blank-p app)
	  (prog1 t (dired-do-open))
	(prog1 t (start-process "" nil app file)))))
  (add-hook 'dirvish-find-entry-hook #'dirvish-open-binaries-externally)

  ;; toggle mark
  (defun dired-toggle-mark (arg &optional interactive)
    (interactive (list current-prefix-arg t) dired-mode)
    (save-excursion
      (beginning-of-line)
      (let ((dired-marker-char (if (equal ?\s (following-char)) ?* ?\s)))
	(dired-mark arg interactive)))
    (forward-line 1))

  :bind
  (:map dirvish-mode-map ; dirvish inherits `dired-mode-map'
	("<left>"  . dired-up-directory)
	("<right>" . dired-find-file)
	("u"       . dired-up-directory)
	("e"       . dired-do-open)
	("o"       . dired-find-file-other-window)
	("m"       . dired-toggle-mark)
	("a"       . dirvish-quick-access)
	("f"       . dirvish-file-info-menu)
	("y"       . dirvish-yank-menu)
	("N"       . dirvish-narrow)
	("^"       . dirvish-history-last)
	("h"       . dirvish-history-jump)	; remapped `describe-mode'
	("s"       . dirvish-quicksort)		; remapped `dired-sort-toggle-or-edit'
	("v"       . dirvish-vc-menu)		; remapped `dired-view-file'
	("TAB"     . dirvish-subtree-toggle)
	("M-f"     . dirvish-history-go-forward)
	("M-b"     . dirvish-history-go-backward)
	("M-l"     . dirvish-ls-switches-menu)
	("M-m"     . dirvish-mark-menu)
	("M-t"     . dirvish-layout-toggle)
	("M-s"     . dirvish-setup-menu)
	("M-e"     . dirvish-emerge-menu)
	("M-j"     . dirvish-fd-jump)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; email
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; mbsync
(use-package mbsync
  :defer t
  :config
  (when (eq system-type 'darwin)
    (setenv "SASL_PATH" "/opt/homebrew/lib/sasl2"))
  (setenv "GPG_TTY" (shell-command-to-string "tty"))
  (setq epg-pinentry-mode 'loopback)
  :hook (mbsync-exit-hook . gnus-group-get-new-news)
  :bind
  (:map gnus-group-mode-map
   ("f" . mbsync)))

;; notmuch
(use-package notmuch
  :defer t
  :commands notmuch)

;; gnus
(use-package gnus
  :defer t
  :hook (gnus-before-startup . (lambda ()
				 (message "Caching pin...")
				 (let ((epg-pinentry-mode 'loopback))
				   (epa-decrypt-file "~/.mutt/id@gmail.com.gpg" "/dev/null"))))
  :init
  (when (eq system-type 'darwin)
    (setenv "SASL_PATH" "/opt/homebrew/lib/sasl2"))
  (setenv "GPG_TTY" (shell-command-to-string "tty"))
  (setq epg-pinentry-mode 'loopback)
  (defvar s/sync-processes 0
    "Counter for active sync processes.")
  (defun s/gnus-get-new-news ()
    "Sync news and mail using fdm and mbsync."
    (interactive)
    (setq s/sync-processes 2)
    (let ((sentinel
	   (lambda (proc event)
	     (when (eq (process-status proc) 'exit)
	       (setq s/sync-processes (1- s/sync-processes))
	       (when (= s/sync-processes 0)
		 (message "Geting new messages... done.")
		 (message "Indexing new messages...")
		 (set-process-sentinel
		  (start-process "notmuch-proc" "*sync-log*" "notmuch" "new")
		  (lambda (nproc nevent)
		    (when (eq (process-status nproc) 'exit)
		      (message "Indexing new messages... done.")
		      (if (get-buffer "*Group*")
			  (with-current-buffer "*Group*"
			    (gnus-group-get-new-news)))))))))))
      (message "Geting new messages...")
      (set-process-sentinel
       (start-process "mbsync-proc" "*sync-log*" "mbsync" "-a")
       sentinel)
      (set-process-sentinel
       (start-process "fdm-proc" "*sync-log*" "fdm" "fetch")
       sentinel)))
  :config
  ;; user
  (setq user-mail-address "id@gmail.com"
	user-full-name "name")
  ;(setq user-mail-address "id@outlook.com"
  ;	user-full-name "name")

  ;; server
  (setq auth-sources
        (list (expand-file-name ".authinfo.json.gpg" home-dir)))
  (setq gnus-select-method '(nnnil ""))
  (add-to-list 'gnus-secondary-select-methods
	       `(nnmaildir "id@gmail.com"
			   (directory (concat home-dir "mail/gmail.com"))
 			   (get-new-mail nil)
			   (gnus-search-engine gnus-search-notmuch
					       (config-file ,(concat home-dir ".notmuch-config"))
					       (remove-prefix ,(concat home-dir "mail/gmail.com/")))))
  (add-to-list 'gnus-secondary-select-methods
	       `(nnmaildir "id@gmail.com/[Gmail]"
			   (directory (concat home-dir "mail/gmail.com/[Gmail]"))
			   (get-new-mail nil)
			   (gnus-search-engine gnus-search-notmuch
					       (config-file ,(concat home-dir ".notmuch-config"))
					       (remove-prefix ,(concat home-dir "mail/gmail.com/[Gmail]/")))))
  (add-to-list 'gnus-secondary-select-methods
	       `(nnmaildir "id@outlook.com"
			   (directory (concat home-dir "mail/outlook.com"))
 			   (get-new-mail nil)
			   (gnus-search-engine gnus-search-notmuch
					       (config-file ,(concat home-dir ".notmuch-config"))
					       (remove-prefix ,(concat home-dir "mail/outlook.com/")))))
  (add-to-list 'gnus-secondary-select-methods
	       `(nnmaildir "archive"
			   (directory (concat home-dir "mail/archive"))
 			   (get-new-mail nil)
			   (gnus-search-engine gnus-search-notmuch
					       (config-file ,(concat home-dir ".notmuch-config"))
					       (remove-prefix ,(concat home-dir "mail/archive/")))))
  (add-to-list 'gnus-secondary-select-methods
	       `(nnmaildir "kernel"
			   (directory (concat home-dir "mail/lore.kernel.org"))
 			   (get-new-mail nil)
			   (gnus-search-engine gnus-search-notmuch
					       (config-file ,(concat home-dir ".notmuch-config"))
					       (remove-prefix ,(concat home-dir "mail/lore.kernel.org/")))))
  (add-to-list 'gnus-secondary-select-methods
	       '(nntp "gwene"
		      (nntp-address "news.gwene.org")))
  (add-to-list 'gnus-secondary-select-methods
  	       '(nntp "kernel"
  		      (nntp-address "nntp.lore.kernel.org")))
  (setq smtpmail-smtp-server "smtp.gmail.com"
	smtpmail-smtp-user "id@gmail.com"
	smtpmail-smtp-service 587
	smtpmail-stream-type 'starttls
	send-mail-function 'smtpmail-send-it
	message-send-mail-function 'smtpmail-send-it)
  ;(setq smtpmail-smtp-server "smtp-mail.outlook.com"
  ;	smtpmail-smtp-user "id@outlook.com"
  ;	smtpmail-smtp-service 587
  ;	smtpmail-stream-type 'starttls
  ;	send-mail-function 'smtpmail-send-it
  ;	message-send-mail-function 'smtpmail-send-it)

  ;; layout
  (setq gnus-always-force-window-configuration t)
  (gnus-add-configuration
   '(summary
     (horizontal 1.0
		 (group 0.2)
		 (summary 1.0 point))))
  (gnus-add-configuration
   '(article
     (horizontal 1.0
		 (group 0.2)
		 (summary 0.3 point)	; point means focus
		 (article 1.0))))	; moving point here causes an error
  (add-hook 'gnus-article-prepare-hook 'gnus-summary-select-article-buffer) ; focus article

  ;; behavior
  (setq gnus-asynchronous t
	gnus-use-header-prefetch 30	; prefetch 30 headers to the next group
	gnus-fetch-old-headers t	; fetch old headers to build threads
	gnus-large-newsgroup nil	; fetch all articles always
	gnus-check-new-newsgroups nil	; don't check new group when starting
	gnus-search-default-engines '((nnmaildir . gnus-search-notmuch))
	gnus-search-notmuch-config-file (concat home-dir ".notmuch-config")
	gnus-use-full-window nil	; use split window
	gnus-parameters			; show all messages
	'((".*" ;; Regex to match all group names
           (display . all))))

  ;; cache articles for imap
  (setq gnus-use-cache t
	gnus-cache-directory temp-dir
	gnus-cache-enter-articles '(ticked dormant read unread)
	gnus-cache-remove-articles nil
	gnus-cacheable-groups "^nntp")

  ;; prefer text format
  (setq mm-discouraged-alternatives '("text/html" "text/richtext")
	mm-text-html-renderer 'shr
	mm-inline-text-html-with-images t
	mm-w3m-safe-url-regexp nil)

  ;; appearance

  ;; apperance - group (topic)
  (add-hook 'gnus-started-hook 'gnus-group-list-all-groups) ; show all group
  (add-hook 'gnus-group-mode-hook 'gnus-topic-mode)
  (eval-after-load 'gnus-topic
    '(progn
       (setq gnus-message-archive-group '((format-time-string "nnmaildir+archive:Sent.%Y-%m"))
	     gnus-topic-topology '(("Gnus" visible)
                                   (("id@gmail.com" visible nil nil))
                                   (("id@outlook.com" visible nil nil))
				   (("archive" visible))
                                   (("misc" visible)))
	     gnus-topic-alist '(("Gnus")
				("id@gmail.com"
				 "nnmaildir+id@gmail.com:Inbox"
				 "nnmaildir+id@gmail.com:Later"
				 "nnmaildir+id@gmail.com/[Gmail]:All Mail"
				 "nnmaildir+id@gmail.com/[Gmail]:Trash"
				 "nnmaildir+id@gmail.com/[Gmail]:Sent Mail"
				 "nnmaildir+id@gmail.com/[Gmail]:Spam"
				 "nnmaildir+id@gmail.com/[Gmail]:Drafts")
				("id@outlook.com"
				 "nnmaildir+id@outlook.com:Inbox"
				 "nnmaildir+id@outlook.com:Later"
				 "nnmaildir+id@outlook.com:Archive"
				 "nnmaildir+id@outlook.com:Deleted"
				 "nnmaildir+id@outlook.com:Sent"
				 "nnmaildir+id@outlook.com:Junk"
				 "nnmaildir+id@outlook.com:Drafts")
				("misc"
				 "nndraft:drafts")))))
  (add-hook 'gnus-topic-mode-hook
            (lambda ()
              (with-current-buffer gnus-group-buffer
		(gnus-topic-move-matching "^nnmaildir\\+archive.*" "archive")
		(gnus-topic-move-matching "^nnmaildir\\+lore.kernel.org.*" "misc"))))

  (defun gnus-user-format-function-T (dummy)
    "Show only the part of the topic name after the colon."
    (let ((topic-name (or name "")))
      (if (string-match ":\\([^:]+\\)$" topic-name)
          (match-string 1 topic-name)
	topic-name)))
  (defun gnus-user-format-function-g (dummy)
    "Show only the part of the topic name after the colon."
    (let ((full-name gnus-tmp-group))
      (if (string-match ":\\([^:]+\\)$" full-name)
          (match-string 1 full-name)
	full-name)))
  (setq gnus-topic-line-format "%i%uT (%A)\n")
  (setq gnus-group-line-format "%p  %(%ug%) (%y)\n")

  ;; appearance - summary
  (defun thread-sort-function (t1 t2)
    (message "t1: %s: %s: %s"
	     (mail-header-date (gnus-thread-header t1))
	     (format-time-string "%m-%d" (gnus-thread-latest-date t1))
	     (mail-header-subject (gnus-thread-header t1)))
    (setq current-header (gnus-thread-header t1))
    (dolist (element (flatten-tree t1))
      (message "date: %s vs. %s"
	       (mail-header-date current-header)
	       (mail-header-date element)))
    (setq current-header (gnus-thread-header t2))
    (dolist (element (flatten-tree t2))
      (message "date: %s vs. %s"
	       (mail-header-date current-header)
	       (mail-header-date element)))
    (time-less-p
     (gnus-thread-latest-date t1)
     (gnus-thread-latest-date t2)))
  (setq gnus-summary-line-format "%U%R%z  %(%&user-date;  %-15,15f  %B%s%)\n"
	gnus-user-date-format-alist '((t . "%Y-%m-%d %H:%M"))
	gnus-sum-thread-tree-false-root ""
	gnus-sum-thread-tree-indent " "
	gnus-sum-thread-tree-leaf-with-other "├► "
	gnus-sum-thread-tree-root ""
	gnus-sum-thread-tree-single-leaf "╰► "
	gnus-sum-thread-tree-vertical "│"
	gnus-summary-thread-gathering-function 'gnus-gather-threads-by-references
	gnus-thread-sort-functions '((not gnus-thread-sort-by-most-recent-date))
	;gnus-thread-sort-functions 'thread-sort-function
	gnus-subthread-sort-functions '(gnus-thread-sort-by-number
					gnus-thread-sort-by-date)
        gnus-sort-gathered-threads-function 'gnus-thread-sort-by-number
        gnus-thread-ignore-subject t)

  ;; check email periodically
  (gnus-demon-add-handler 'gnus-demon-scan-mail 5 5)
  (gnus-demon-init)
  :bind
  (:map gnus-group-mode-map
	("f" . s/gnus-get-new-news)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; xwidget
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; xwwp
(use-package xwwp-follow-link
  :straight (xwwp-follow-link
	     :type git
	     :host github
	     :repo "canatella/xwwp")
  :bind (:map xwidget-webkit-mode-map
              ("v" . xwwp-follow-link)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ai
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; install required inheritenv dependency:
(use-package inheritenv
  :straight (inheritenv
	     :type git :host github
	     :repo "purcell/inheritenv"))

(use-package monet
  :straight (monet
	     :type git :host github
	     :repo "stevemolitor/monet"))

;; install claude-code.el, using :depth 1 to reduce download size:
(use-package claude-code
  :straight (claude-code
	     :type git :host github
	     :repo "stevemolitor/claude-code.el"
	     :branch "main" :depth 1
             :files ("*.el" (:exclude "images/*")))
  :bind-keymap
  ("C-c c" . claude-code-command-map) ;; or your preferred key
  ;; Optionally define a repeat map so that "M" will cycle thru Claude auto-accept/plan/confirm modes after invoking claude-code-cycle-mode / C-c M.
  :bind
  (:repeat-map my-claude-code-map ("M" . claude-code-cycle-mode))
  :config

;; optional IDE integration with Monet
  (add-hook 'claude-code-process-environment-functions #'monet-start-server-function)
  (monet-mode 1)

  (setq claude-code-terminal-backend 'vterm)
  (claude-code-mode))

(use-package ai-code
  :straight (:host github :repo "tninja/ai-code-interface.el")
  :config
  (ai-code-set-backend 'codex)

  ;; Enable global keybinding for the main menu
  (global-set-key (kbd "C-c x") #'ai-code-menu)
  ;; Optional: Set up Magit integration for AI commands in Magit popups
  (with-eval-after-load 'magit
    (ai-code-magit-setup-transients)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; enhanced basic commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; reload .emacs
(defun s/reload-init-file ()
  "reload .emacs"
  (interactive)
  (when (y-or-n-p "Rebuild Packages?")
    (byte-recompile-directory user-emacs-directory 0))
  ;; early-init.el
  (when (file-exists-p (expand-file-name "early-init.elc" user-dir))
    (delete-file (expand-file-name "early-init.elc" user-dir))
    (byte-compile-file (expand-file-name "early-init.el" user-dir))
    (load-file (expand-file-name "early-init.elc" user-dir)))
  ;; init.el
  (when (file-exists-p (expand-file-name "init.elc" user-dir))
    (delete-file (expand-file-name "init.elc" user-dir))
    (byte-compile-file (expand-file-name "init.el" user-dir))
    (load-file (expand-file-name "init.elc" user-dir))))
;(global-set-key (kbd "C-c r") 's/reload-init-file)
;(global-set-key (kbd "C-c r") 'restart-emacs)

;; beginning of line
(defun s/beginning-of-line ()
  "beginning of line like vscode"
  (interactive)
  (setq prev-point (point))
  ;(message "first: %s" (point))
  (beginning-of-line-text)
  ;(message "second: %s" (point))
  (if (eq prev-point (point))
    (beginning-of-line)))
(global-set-key (kbd "C-a") 's/beginning-of-line)
