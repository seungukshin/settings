;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; check statup time
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; startup time
(defun efs/display-startup-time ()
  (message
   "Emacs loaded in %s seconds with %d garbage collections."
   (emacs-init-time)
   gcs-done))

(add-hook 'emacs-startup-hook #'efs/display-startup-time)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; basic configure
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; directories
(setq home-dir (expand-file-name "~/")
      user-dir user-emacs-directory
      temp-dir (concat user-dir ".cache/")
      elpa-dir (concat user-dir "elpa/"))
(unless (file-exists-p temp-dir)
  (make-directory temp-dir t))

;; exec path
(when (eq system-type 'windows-nt)
  (add-to-list 'exec-path (concat home-dir "AppData/Roaming/emacs/bin/")))
(when (eq system-type 'darwin)
  (add-to-list 'exec-path (concat home-dir "bin/"))
  (add-to-list 'exec-path "/opt/homebrew/bin/"))

;; proxy
(when nil
  (setq url-proxy-services
	'(("no_proxy" . "^\\(localhost\\|192\\.168\\..*\\)")
	  ("http" . "proxy.com:8080")
	  ("https" . "proxy.com:8080"))))

;; debug
(setq debug-on-error nil)

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
 		    (font-spec :name "Inconsolata Nerd Font" :size 16 :height 16))
  (set-fontset-font "fontset-default" 'kana
 		    (font-spec :name "Noto Sans Mono CJK JP" :size 16 :height 16))
  (set-fontset-font "fontset-default" 'hangul
 		    (font-spec :name "D2Coding" :size 16 :height 16))
  (set-frame-font "fontset-default" nil t))

;; theme
(use-package monokai-theme
  :ensure t
  :config
  (load-theme 'monokai t))

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
  :config
  (setq doom-modeline-enable-word-count nil
	doom-modeline-height 16))

(setq line-number-mode t			; display line number in mode line
      column-number-mode t			; display column number in mode line
      size-indication-mode t			; display file size in mode line
      display-time-format "%F %a %T"		; display time in mode line
      display-time-interval 1)
(display-time-mode)

;; goggles
(use-package goggles
  :hook ((prog-mode text-mode) . goggles-mode)
  :config
  (setq goggles-pulse t))

;; scroll
(pixel-scroll-precision-mode)			; smooth scrolling
(setopt mouse-wheel-tilt-scroll t
	mouse-wheel-flip-direction t)
(blink-cursor-mode -1)				; Steady cursor

;; tab bar
(tab-bar-mode 1)				; enable tab bar
(setq tab-bar-show 1				; hide bar if <= 1 tabs open
      tab-bar-close-button-show t		; show tab close / X button
      tab-bar-new-tab-choice "*dashboard*"	; buffer to show in new tabs
      tab-bar-tab-hints t			; show tab numbers
      tab-bar-auto-width t
      tab-bar-auto-width-max '(240 20)
      tab-bar-auto-width-min '(240 20)
      tab-bar-format '(tab-bar-format-tabs tab-bar-separator))

(custom-set-faces
 '(tab-bar ((t (:inherit mode-line-inactive))))
 '(tab-bar-tab ((t (:inherit mode-line))))
 '(tab-bar-tab-inactive ((t (:inherit mode-line-inactive)))))
;(set-face-attribute 'tab-bar-tab nil
;                    :foreground "#f0f0f0"
;                    :background "#672179")
;(set-face-attribute 'tab-bar-tab-inactive nil
;                    :foreground "#339cda"
;                    :background "#1e1e1e")

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
(set-file-name-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(modify-coding-system-alist 'file "" 'utf-8-unix)

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
;; sassion
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
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))

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
   ("C-c m"   . consult-man)
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
   ("C-c o"   . helm-resume)
   ("C-c fa"  . s/helm-fd-project-root)
   ("C-c fd"  . s/helm-fd-directory)
   ("C-c fc"  . s/helm-fd-current-directory)
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
  (("C-c ra" . helm-do-ag-project-root)
   ("C-c rd" . helm-do-ag)
   ("C-c rf" . helm-do-ag-this-file)
   ("C-c rb" . helm-do-ag-buffers)
   ("C-c ro" . helm-ag-pop-stack)))

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
  (("C-c ss" . helm-swoop)
   ("C-c sr" . helm-swoop-back-to-last-point)
   ("C-c sm" . helm-multi-swoop)
   ("C-c sa" . helm-multi-swoop-all))
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
   ("C-c cs" . helm-cscope-find-this-symbol)
   ("C-c cg" . helm-cscope-find-global-definition)
   ("C-c cd" . helm-cscope-find-called-this-function)
   ("C-c cc" . helm-cscope-find-calling-this-function)
   ("C-c ct" . helm-cscope-find-this-text-string)
   ("C-c ce" . helm-cscope-find-egrep-pattern)
   ("C-c cf" . helm-cscope-find-this-file)
   ("C-c ci" . helm-cscope-find-files-including-file)
   ("C-c co" . helm-cscope-pop-mark)))

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
   ("C-c gs" . helm-gtags-find-symbol)
   ("C-c gg" . helm-gtags-find-tag)
   ("C-c gr" . helm-gtags-find-rtag)
   ("C-c gp" . helm-gtags-find-pattern)
   ("C-c gf" . helm-gtags-find-files)
   ("C-c go" . helm-gtags-pop-stack)))

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
  :config
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
  :hook
  ;; Auto parenthesis matching
  (prog-mode . electric-pair-mode))

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

(use-package dockerfile-ts-mode
  :straight (:type built-in)
  :defer t
  :mode (("\\Dockerfile\\'" . dockerfile-ts-mode)
	 ("\\.dockerignore\\'" . dockerfile-ts-mode)))

(use-package yaml-ts-mode
  :straight (:type built-in)
  :mode "\\.ya?ml\\'")

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
    :hook (org-mode . flyspell-mode)		; spell checking!
    :config
    (setq org-directory (concat home-dir "org/")
	  org-agenda-dir (concat home-dir "org/")
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
	  org-startup-folded 'showall)

    ;; heading font size
    (custom-set-faces '(org-level-1 ((t (:height 1.0))))
		      '(org-level-2 ((t (:height 1.0))))
		      '(org-level-3 ((t (:height 1.0))))
		      '(org-level-4 ((t (:height 1.0))))
		      '(org-level-5 ((t (:height 1.0))))
		      '(org-level-6 ((t (:height 1.0)))))

    ;; add visibility
    (add-hook 'org-cycle-hook
	      (lambda (symbol-state)
		(interactive)
		(let ((state (symbol-name symbol-state)))
		  (if (string= state "subtree")
		      (org-entry-put nil "visibility" "all")
		    (org-entry-put nil "visibility" state)))))

    ;; citation
    (require 'oc-csl)
    (add-to-list 'org-export-backends 'md)

    ;; Make org-open-at-point follow file links in the same window
    (setf (cdr (assoc 'file org-link-frame-setup)) 'find-file)

    ;; Make exporting quotes better
    (setq org-export-with-smart-quotes t)

    ;; Refile configuration
    (setq org-outline-path-complete-in-steps nil)
    (setq org-refile-use-outline-path 'file)

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

    ;; Advanced: Custom link types
    ;; This example is for linking a person's 7-character ID to their page on the
    ;; free genealogy website Family Search.
    (setq org-link-abbrev-alist
	  '(("family_search" . "https://www.familysearch.org/tree/person/details/%s")))

    (setq org-display-inline-images t
	  org-display-remote-inline-images t
	  org-redisplay-inline-images t
	  org-startup-with-inline-images t
	  org-image-actual-width 800)
    (add-hook 'org-babel-after-execute-hook 'org-redisplay-inline-images)

    (defun org-image-resize (frame)
      (when (derived-mode-p 'org-mode)
	(setq org-image-actual-width (/ (window-pixel-width) 2))
	(org-redisplay-inline-images)))
    (add-hook 'window-size-change-functions 'org-image-resize)

    (org-babel-do-load-languages
     'org-babel-load-languages
     '((dot . t))) ; this line activates dot

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
     (:map org-transclusion-map
      ("C-c o A" . org-transclusion-add-all)
      ("C-c o r" . org-transclusion-remove)
      ("C-c o R" . org-transclusion-remove-all)
      ("C-c o T" . org-transclusion-activate)
      ("C-c o D" . org-transclusion-deactivate)
      ("C-c o d" . org-transclusion-detach)))))

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
(global-set-key (kbd "C-c t") 's/tmux-execute-current-line-or-region)

(use-package vterm
  :defer t
  ;:ensure t
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

(use-package dirvish
  :defer t
  :init
  (dirvish-override-dired-mode)
  :custom
  ;(dirvish-side-follow-mode)
  (dirvish-quick-access-entries ; It's a custom option, `setq' won't work
   '(("h" "~/"                          "Home")
     ("d" "~/Downloads/"                "Downloads")
     ("o" "~/org/"                      "org")
     ("t" "~/.local/share/Trash/files/" "TrashCan")))
  :config
  ;; fix for Listing directory failed but ‘access-file’ worked
  (when (eq system-type 'darwin)
    (setq insert-directory-program "/opt/homebrew/bin/gls"))
  ;(dirvish-peek-mode) ; Preview files in minibuffer
  ;; (dirvish-side-follow-mode) ; similar to `treemacs-follow-mode'
  (setq dirvish-header-line-height '(16 . 16)
	dirvish-header-line-format
	'(:left (path) :right (free-space))
  	dirvish-mode-line-height '(16 . 16)
	dirvish-mode-line-format
	'(:left (sort file-time " " file-size symlink) :right (omit yank index)))
  (setq dirvish-attributes
        '(nerd-icons file-time file-size collapse subtree-state vc-state git-msg))
  (setq delete-by-moving-to-trash t)
  (setq dired-listing-switches
        "-l --almost-all --human-readable --group-directories-first --no-group")

  ;; use an external app
  (setq dirvish-external-exts nil)
  (setq dired-guess-shell-alist-user nil)
  (let ((dirvish-default-app (cond ((eq system-type 'darwin) "open")
				   ((eq system-type 'windows-nt) "start")
				   (t "xdg-open")))
	(dirvish-external-apps '(("docx" "open -a 'Microsoft Word'")
				 ("doc" ,dirvish-default-app)
				 ("xlsx" "open -a 'Microsoft Excel'")
				 ("xls" ,dirvish-default-app)
				 ("pptx" "open -a 'Microsoft PowerPoint'")
				 ("ppt" ,dirvish-default-app))))
    (dolist (element dirvish-external-apps)
      (add-to-list 'dirvish-external-exts (car element) t)
      (add-to-list 'dired-guess-shell-alist-user (list (concat "\\." (car element) "\\'") (cdr element)))))
  (defun dirvish-open-binaries-externally (file fn)
    "When FN is not `dired', open binary FILE externally."
    (when-let* (((not (eq fn 'dired)))
		((file-exists-p file))
		((not (file-directory-p file)))
		((member (downcase (or (file-name-extension file) ""))
			 dirvish-external-exts)))
      ;; return t to terminate `dirvish--find-entry'.
      (prog1 t (dired-do-open))))
  (add-hook 'dirvish-find-entry-hook #'dirvish-open-binaries-externally)

  :bind ; Bind `dirvish|dirvish-side|dirvish-dwim' as you see fit
  (:map dirvish-mode-map ; Dirvish inherits `dired-mode-map'
   ("<left>"  . dired-up-directory)
   ("<right>" . dired-find-file)
   ("u"       . dired-up-directory)
   ("o"       . dired-find-file-other-window)
   ("a"       . dirvish-quick-access)
   ("f"       . dirvish-file-info-menu)
   ("y"       . dirvish-yank-menu)
   ("N"       . dirvish-narrow)
   ("^"       . dirvish-history-last)
   ("h"       . dirvish-history-jump) ; remapped `describe-mode'
   ("s"       . dirvish-quicksort)    ; remapped `dired-sort-toggle-or-edit'
   ("v"       . dirvish-vc-menu)      ; remapped `dired-view-file'
   ("TAB"     . dirvish-subtree-toggle)
   ("M-f"     . dirvish-history-go-forward)
   ("M-b"     . dirvish-history-go-backward)
   ("M-l"     . dirvish-ls-switches-menu)
   ("M-m"     . dirvish-mark-menu)
   ("M-t"     . dirvish-layout-toggle)
   ("M-s"     . dirvish-setup-menu)
   ("M-e"     . dirvish-emerge-menu)
   ("M-j"     . dirvish-fd-jump)))

(use-package notmuch
  :defer t
  :commands notmuch)

;; gnus
(use-package gnus
  :defer t
  :config
  ;; user
  (setq user-mail-address "seunguk.shin@gmail.com"
	user-full-name "Seunguk Shin")

  ;; server
  (setq gnus-select-method '(nnnil ""))
  (setq gnus-secondary-select-methods
	'((nnimap "seunguk.shin@gmail.com"
		  (nnimap-address "imap.gmail.com")
		  (nnimap-server-port 993)
		  (nnimap-stream ssl)
		  (nnir-search-engine imap)
		  (nnmail-expiry-target "nnimap+seunguk.shin@gmail.com:[Gmail]/Trash")
		  (nnmail-expiry-wait immediate))
	  (nnmaildir "archives"
		     (directory (concat home-dir "gnus/archives"))
		     (get-new-mail nil)
		     (nnir-search-engine notmuch))
	  (nntp "nntp.lore.kernel.org"
		(nntp-address "nntp.lore.kernel.org"))))

  (setq smtpmail-smtp-server "smtp.gmail.com"
	smtpmail-smtp-service 587
	send-mail-function 'smtpmail-send-it
	message-send-mail-function 'smtpmail-send-it)

  (require 'nnir)
  (setq nnir-notmuch-program "notmuch"
	nnir-notmuch-remove-prefix (concat home-dir "gnus/archives/"))

  (setq gnus-asynchronous t
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

  (setq-default gnus-summary-line-format "%U%R%z  %(%&user-date;  %-15,15f  %B%s%)\n"
		gnus-user-date-format-alist '((t . "%Y-%m-%d %H:%M"))
		gnus-summary-thread-gathering-function 'gnus-gather-threads-by-references
		gnus-thread-sort-functions '(gnus-thread-sort-by-date)
		gnus-sum-thread-tree-false-root ""
		gnus-sum-thread-tree-indent " "
		gnus-sum-thread-tree-leaf-with-other "├► "
		gnus-sum-thread-tree-root ""
		gnus-sum-thread-tree-single-leaf "╰► "
		gnus-sum-thread-tree-vertical "│"))

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
