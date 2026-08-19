(setq make-backup-files nil
      user-emacs-directory "/home/user/.config/emacs/")
(global-display-line-numbers-mode 1)
(setq-default truncate-lines t)
(if (fboundp 'normal-top-level-add-subdirs-to-load-path)
    (normal-top-level-add-subdirs-to-load-path))
