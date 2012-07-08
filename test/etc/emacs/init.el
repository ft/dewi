(setq diff-switches '("-u"))
(setq initial-scratch-message nil)
(setq query-replace-highlight t)
(setq search-highlight t)
(setq woman-use-own-frame nil)
(setq woman-use-topic-at-point t)

(setq-default inhibit-startup-message t)
(setq-default inhibit-startup-echo-area-message t)
(setq-default require-final-newline t)
(setq-default scroll-step 1)
(setq-default indent-tabs-mode nil)
(setq-default sentence-end-double-space nil)
(setq-default fill-column 79)

(fset 'yes-or-no-p 'y-or-n-p)

(column-number-mode t)
(display-time-mode -1)
(global-font-lock-mode t)
(line-number-mode t)
(prefer-coding-system 'utf-8)

(defun info-mode ()
  "Take the current buffer (hopefully) containing texinfo data, and launch it
in the `info' browser. Funny, that emacs doesn't have this by default. -ft"
  (interactive)
  (let ((fn (buffer-file-name)))
    (kill-buffer (current-buffer))
    (info fn)))
