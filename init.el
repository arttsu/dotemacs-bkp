(defun my/mac-p ()
  "Return t if Emacs is running on a mac."
  (equal system-type 'darwin))

(load "~/.emacs.d/local.el")

(when (my/mac-p)
  (setenv "PATH" (concat "/usr/local/bin:" (getenv "PATH")))
  (push "/usr/local/bin" exec-path))

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
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

(straight-use-package 'use-package)

(use-package hydra)

(use-package auto-minor-mode)

(use-package org-ql)

(setq shell-file-name "/bin/sh")

(use-package exec-path-from-shell
  :if (my/mac-p)
  :config
  (exec-path-from-shell-initialize))

(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024))

(setq create-lockfiles nil)
(setq make-backup-files nil)

(setq global-auto-revert-non-file-buffers t)

(global-auto-revert-mode)

(setq custom-file (concat user-emacs-directory "custom.el"))

(when (file-exists-p custom-file)
  (load custom-file))

(when (my/mac-p)
  (setq mac-right-option-modifier nil))

(use-package super-save
  :init
  (setq super-save-auto-save-when-idle t)
  (setq auto-save-default nil)
  (setq super-save-exclude '(".sbt" "project/"))
  :config
  (add-to-list 'super-save-triggers 'find-file)
  (add-to-list 'super-save-triggers 'ace-window)
  (add-to-list 'super-save-triggers 'vterm)
  (add-to-list 'super-save-triggers 'vterm-other-window)
  (add-to-list 'super-save-triggers 'tab-next)
  (add-to-list 'super-save-triggers 'tab-previous)
  (add-to-list 'super-save-triggers 'tab-switch)
  (add-to-list 'super-save-triggers 'tab-bar-history-back)
  (add-to-list 'super-save-triggers 'tab-bar-history-forward)
  (add-to-list 'super-save-triggers 'delete-window)
  (add-to-list 'super-save-triggers 'magit-status)
  (super-save-mode +1))

(use-package org
  :init
  (setq org-agenda-files '("~/org/planner/personal.org"
                           "~/org/planner/work.org"
                           "~/org/planner/calendar.org"))
  (setq org-confirm-babel-evaluate nil)
  (setq org-startup-indented t)
  (setq org-export-copy-to-kill-ring 'if-interactive)
  (setq org-export-with-sub-superscripts '{})
  (setq org-use-sub-superscripts '{})
  (setq org-blank-before-new-entry '((heading . t) (plain-list-item . auto)))
  (setq org-clock-sound "~/.emacs.d/assets/mixkit-attention-bell-ding-586.wav"))

(defvar my/capture-prompt-history nil)

(defun my/capture-prompt (prompt var)
  (make-local-variable var)
  (set var (read-string (concat prompt ": ") nil my/capture-prompt-history)))

(defun my/capture-template-path (template-name)
  (format "~/.emacs.d/capture-templates/%s.txt" template-name))

(with-eval-after-load 'org-capture
  (setq org-capture-templates
        (list
         `("i" "Inbox" entry (file "~/org/planner/inbox.org") (file ,(my/capture-template-path "inbox-entry")))
         `("f" "Folder")
         `("fp" "Personal" entry (file "~/org/planner/personal.org") (file ,(my/capture-template-path "folder")))
         `("fw" "Work" entry (file "~/org/planner/work.org") (file ,(my/capture-template-path "folder")))
         `("fs" "Someday" entry (file "~/org/planner/someday.org") (file ,(my/capture-template-path "folder")))
         `("p" "Project")
         `("pp" "Personal" entry (file "~/org/planner/personal.org") (file ,(my/capture-template-path "project")))
         `("pw" "Work" entry (file "~/org/planner/work.org") (file ,(my/capture-template-path "project"))))))

(with-eval-after-load 'org-refile
  (setq org-refile-use-outline-path 'file)
  (setq org-outline-path-complete-in-steps nil)

  (setq org-refile-targets
        '((("~/org/planner/personal.org" "~/org/planner/work.org" "~/org/planner/calendar.org" "~/org/planner/someday.org") :level . 1)
          (("~/org/planner/inbox.org" "~/org/planner/reading.org" "~/org/planner/music.org") :level . 0))))

(defun my/day-agenda (keys title files)
  `(,keys
    ,title
    ((agenda "" ((org-agenda-span 1)
                 (org-agenda-skip-scheduled-if-done t)
                 (org-agenda-skip-deadline-if-done t)
                 (org-agenda-skip-timestamp-if-done t)))
     (todo "TODO" ((org-agenda-overriding-header "TODOs") (org-agenda-skip-function '(org-agenda-skip-entry-if 'deadline 'scheduled)))))
    ((org-agenda-compact-blocks)
     (org-agenda-files ',files))))

(with-eval-after-load 'org-agenda
  (setq org-agenda-custom-commands
        (list
         (my/day-agenda "p" "Personal agenda" '("~/org/planner/personal.org" "~/org/planner/calendar.org"))
         (my/day-agenda "w" "Work agenda" '("~/org/planner/work.org"))
         '("i" "Inbox" ((todo "TODO")) ((org-agenda-files '("~/org/planner/inbox.org")))))))

(use-package gnuplot)

(use-package ob-restclient
  :after org-babel-load-languages
  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((restclient . t))))

(use-package org-auto-tangle
  :hook (org-mode . org-auto-tangle-mode))

(use-package org-roam
  :init
  (setq org-roam-v2-ack t)
  (setq org-roam-directory "~/org/zettelkasten")
  :config
  (org-roam-setup)
  (org-roam-db-autosync-mode))

(use-package org-roam-ui
  :after org-roam
  :init
  (setq org-roam-ui-sync-theme t)
  (setq org-roam-ui-follow t)
  (setq org-roam-ui-update-on-save t)
  (setq org-roam-ui-open-on-start t))

(use-package ox-slack)

(use-package ox-jira)

(use-package htmlize)

(use-package ox-reveal)

(use-package toc-org
  :hook ((org-mode markdown-mode) . toc-org-mode))

(use-package anki-editor
  :init
  (setq anki-editor-create-decks t))

(add-to-list 'auto-mode-alist '("\\.anki\\'" . org-mode))
(add-to-list 'auto-minor-mode-alist '("\\.anki\\'" . anki-editor-mode))

(defun my-anki-editor-note-at-point ()
  (let ((org-trust-scanner-tags t)
        (deck (or (org-entry-get-with-inheritance "ANKI_DECK") "Default"))
        (note-id (org-entry-get nil anki-editor-prop-note-id))
        (note-type "Basic_LaTeX")
        (tags (anki-editor--get-tags))
        (fields (my-anki-editor-build-fields)))
    `((deck . ,deck)
      (note-id . ,(string-to-number (or note-id "-1")))
      (note-type . ,note-type)
      (tags . ,(-filter (lambda (tag) (not (string= tag "ankiCard"))) tags))
      (fields . ,fields))))

(defun my-anki-editor-build-fields ()
  (let* ((element (org-element-at-point))
         (front (substring-no-properties
                 (org-element-property :raw-value element)))
         (contents-begin (org-element-property :contents-begin element))
         (contents-end (org-element-property :contents-end element))
         (back (org-export-string-as (buffer-substring contents-begin contents-end)
                                     anki-editor--ox-anki-html-backend
                                     t
                                     anki-editor--ox-export-ext-plist)))
    `(("Front" . ,front) ("Back" . ,back))))

(defun my-anki-editor-map-note-entries (func &optional match scope &rest skip)
  (let ((org-use-property-inheritance nil))
    (org-map-entries func (concat match "&ankiCard") scope skip)))

(defun my-anki-editor-push-notes ()
  (interactive)
  (anki-editor-mode 1)
  (advice-add 'anki-editor-map-note-entries :override
              #'my-anki-editor-map-note-entries
              '((name . my-anki-editor-map-note-entries-override)))
  (advice-add 'anki-editor-note-at-point :override
              #'my-anki-editor-note-at-point
              '((name . my-anki-editor-note-at-point-override)))
  (anki-editor-push-notes)
  (advice-remove 'anki-editor-map-note-entries 'my-anki-editor-map-note-entries-override)
  (advice-remove 'anki-editor-note-at-point 'my-anki-editor-note-at-point-override)
  (anki-editor-mode -1))

(use-package notdeft
  :straight (notdeft :type git :host github :repo "hasu/notdeft"
                     :files ("*.el" "xapian"))
  :init
  (setq notdeft-directory "~/org/notes")
  (setq notdeft-directories '("~/org/notes" "~/org/zettelkasten"))
  (setq notdeft-notename-function #'my/notdeft-title-to-filename)
  (setq notdeft-new-file-data-function #'my-notdeft-new-file-data)
  (setq notdeft-xapian-program (expand-file-name "straight/build/notdeft/xapian/notdeft-xapian" user-emacs-directory))
  :config
  (notdeft-install))

(defun my-notdeft-new-file-data (dir notename ext data title)
  (let* ((notename (or notename
                       (when title
                         (notdeft-title-to-notename title))))
         (file (if notename
                   (notdeft-make-filename notename ext dir)
                 (notdeft-generate-filename ext dir))))
    (cons file (or data (format "#+TITLE: %s" title)))))

(defun my/notdeft-title-to-filename (title)
  (let ((timestamp (format-time-string "%Y%m%d%H%M%S"))
        (default-title (notdeft-default-title-to-notename title)))
    (format "%s-%s" timestamp default-title)))

(use-package org-bookmark-heading)

(setq inhibit-startup-screen t)
(setq initial-scratch-message nil)
(setq initial-major-mode 'org-mode)

(scroll-bar-mode -1)
(tool-bar-mode -1)
(menu-bar-mode -1)

(setq visible-bell t)

(if (boundp 'pixel-scroll-precision-mode)
    (pixel-scroll-precision-mode +1)
  (pixel-scroll-mode +1))

(add-hook 'prog-mode-hook 'display-line-numbers-mode)

(fset 'yes-or-no-p 'y-or-n-p)

(tab-bar-mode)
(tab-bar-history-mode)

(set-face-attribute 'default nil :font "Iosevka Comfy" :height my/font-height)
(set-frame-font "Iosevka Comfy" nil t)

(defun my/apply-theme (appearance)
  (mapc #'disable-theme custom-enabled-themes)
  (pcase appearance
    ('light (modus-themes-load-operandi))
    ('dark (modus-themes-load-vivendi))))

(use-package modus-themes
  :init
  (setq modus-themes-bold-constructs nil)
  (setq modus-themes-italic-constructs t)
  (setq modus-themes-links '(italic background))
  (setq modus-themes-mode-line '(accented))
  (setq modus-themes-tabs-accented t)
  (setq modus-themes-paren-match '(intense))
  (setq modus-themes-region '(no-extend))
  (setq modus-themes-org-blocks 'gray-background)
  (setq modus-themes-headings '((1 . (overline background 1.5))
                                (2 . (overline background 1.3))
                                (3 . (1.1))))
  (setq modus-themes-prompts '(background bold))
  :config
  (when (boundp 'ns-system-appearance-change-functions)
    (add-hook 'ns-system-appearance-change-functions #'my/apply-theme))
  (my/apply-theme 'light))

(use-package pulsar
  :init
  (setq pulsar-pulse-on-window-change t)
  :config
  (pulsar-global-mode))

(use-package ace-window
  :init
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  (setq aw-scope 'frame)
  :bind
  (("M-o" . ace-window)))

(use-package transpose-frame)

(use-package neotree
  :bind
  (("M-<f7>" . #'my-neotree-toggle)))

(defun my-neotree-toggle ()
  (interactive)
  (if (neo-global--window-exists-p)
      (neotree-hide)
    (if (project-current)
        (neotree-projectile-action)
      (neotree-dir (file-name-directory buffer-file-name)))))

(when (my/mac-p)
  (use-package reveal-in-osx-finder
    :bind
    (("C-c z" . #'reveal-in-osx-finder))))

(use-package blamer
  :bind
  (("s-i" . blamer-show-posframe-commit-info))
  :custom
  (blamer-idle-time 0.5)
  (blamer-min-offset 70)
  (blamer-max-lines 10)
  :config
  (global-blamer-mode))

(defun blamer-callback-show-commit-diff (commit-info)
  (interactive)
  (let ((commit-hash (plist-get commit-info :commit-hash)))
    (when commit-hash
      (magit-show-commit commit-hash))))

(defun blamer-callback-magit-log-file (commit-info)
  (interactive)
  (magit-log-buffer-file)
  (let ((commit-hash (plist-get commit-info :commit-hash)))
    (when commit-hash
      (run-with-idle-timer 1 nil (lambda (commit-hash)
                                   (goto-char (point-min))
                                   (search-forward (substring commit-hash 0 7))
                                   (set-mark (point-at-bol))
                                   (goto-char (point-at-eol)))
                           commit-hash))))

(setq blamer-bindings '(("<mouse-3>" . blamer-callback-magit-log-file)
                        ("<mouse-1>" . blamer-callback-show-commit-diff)))

(setq require-final-newline t)

(setq-default indent-tabs-mode nil)

(global-set-key (kbd "M-z") 'zap-up-to-char)

(global-subword-mode)

(use-package smartparens
  :after whole-line-or-region
  :init
  (add-hook 'emacs-lisp-mode-hook #'smartparens-strict-mode)
  (add-hook 'eval-expression-minibuffer-setup-hook #'smartparens-mode)
  (add-hook 'scala-mode-hook #'smartparens-mode)
  (add-hook 'python-mode-hook #'smartparens-mode)
  (add-hook 'sql-mode-hook #'smartparens-mode)
  (add-hook 'clojure-mode-hook #'smartparens-strict-mode)
  (add-hook 'ruby-mode-hook #'smartparens-mode)
  :config
  (require 'smartparens-config)
  :bind
  (:map smartparens-strict-mode-map
        ("C-<right>" . sp-forward-slurp-sexp)
        ("C-<left>" . sp-backward-slurp-sexp)
        ("M-<right>" . sp-forward-barf-sexp)
        ("M-<left>" . sp-backward-barf-sexp)
        ("C-w" . my/whole-line-or-region-sp-kill-region)
        :map smartparens-mode-map
        ("C-<right>" . sp-forward-slurp-sexp)
        ("C-<left>" . sp-backward-slurp-sexp)
        ("M-<right>" . sp-forward-barf-sexp)
        ("M-<left>" . sp-backward-barf-sexp)))

;; https://github.com/purcell/whole-line-or-region/issues/17#issuecomment-781988534
(defun my/whole-line-or-region-sp-kill-region (prefix)
  "Call `sp-kill-region' on region or PREFIX whole lines."
  (interactive "*p")
  (whole-line-or-region-wrap-beg-end 'sp-kill-region prefix))

(defun my/org-unbind-avy-goto ()
  (local-unset-key (kbd "C-'")))

(add-hook 'org-mode-hook #'my/org-unbind-avy-goto)

(use-package avy
  :init
  (setq avy-single-candidate-jump t)
  :config
  (avy-setup-default)
  (setf (alist-get ?n avy-dispatch-alist) #'my/avy-action-copy-charseq)
  (setf (alist-get ?y avy-dispatch-alist) #'my/avy-action-yank-charseq)
  (setf (alist-get ?Y avy-dispatch-alist) #'my/avy-action-yank-line)
  (setf (alist-get ?. avy-dispatch-alist) #'my/avy-action-embark)
  (setf (alist-get ?\; avy-dispatch-alist) #'my/avy-action-embark-dwim)
  :bind
  (("C-;" . avy-goto-char-timer)
   ("M-;" . avy-pop-mark)
   ("M-g g" . avy-goto-line)
   ("M-g G" . avy-goto-end-of-line)))

(use-package multiple-cursors
  :config
  (define-key mc/keymap (kbd "<return>") nil)
  :bind
  ("C-+" . #'mc/mark-next-like-this)
  ("C-c m" . #'mc/edit-lines)
  ("C-c M" . #'mc/mark-all-dwim)
  ("C-S-<mouse-1>" . #'mc/add-cursor-on-click)
  ("C-<return>" . #'set-rectangular-region-anchor))

(use-package expand-region
  :bind
  ("C-=" . 'er/expand-region))

(use-package iy-go-to-char
  :bind
  ("C-c f" . iy-go-to-char)
  ("C-c F" . iy-go-to-char-backward)
  ("C-c t" . iy-go-up-to-char)
  ("C-c T" . iy-go-up-to-char-backward)
  ("C-c ;" . iy-go-to-or-up-to-continue)
  ("C-c ," . iy-go-to-or-up-to-continue-backward))

(use-package crux
  :bind
  (("C-k" . crux-smart-kill-line)
   ("C-o" . crux-smart-open-line)
   ("C-S-o" . crux-smart-open-line-above)
   ("C-^" . crux-top-join-line)))

(use-package char-fold
  :demand t
  :init
  (setq char-fold-symmetric t)
  (setq search-default-mode #'char-fold-to-regexp))

(use-package reverse-im
  :after char-fold
  :demand t
  :init
  (setq reverse-im-input-methods '("ukrainian-computer" "russian-computer"))
  (setq reverse-im-char-fold t)
  (setq reverse-im-read-char-advice-function #'reverse-im-read-char-include)
  :config
  (add-to-list 'reverse-im-read-char-include-commands 'org-agenda)
  (reverse-im-mode t))

(use-package whole-line-or-region
  :demand
  :config
  (whole-line-or-region-global-mode)
  :bind
  (("M-/" . whole-line-or-region-comment-dwim)))

(use-package vertico
  :config
  (vertico-mode))

(use-package savehist
  :config
  (savehist-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless)))

(use-package marginalia
  :demand
  :config
  (marginalia-mode)
  :bind
  (:map minibuffer-local-map
        ("M-A" . marginalia-cycle)))

(use-package embark
  :bind
  (("C-." . embark-act)
   ("M-." . embark-dwim)))

(use-package embark-consult
  :after (embark consult))

(use-package company
  :init
  (setq company-minimum-prefix-length 2)
  (setq company-idle-delay 0.2)
  (setq company-selection-wrap-around t)
  (setq company-dabbrev-downcase nil)
  (setq company-show-numbers t)
  :config
  (global-company-mode))

(defun my/point-at-end-of-line ()
  (save-excursion (move-end-of-line nil) (point)))

(defun my/current-line-empty-p ()
  (save-excursion
    (beginning-of-line)
    (looking-at-p "[[:blank:]]*$")))

(defun my/save-all-buffers ()
  (interactive)
  (save-some-buffers t))

(defun my/in-src-block-p ()
  (memq (org-element-type (org-element-context))
        '(inline-src-block src-block)))

(defun my/forward-to-src-block ()
  (if (my/in-src-block-p)
      (org-babel-goto-src-block-head)
    (org-babel-next-src-block)))

(defun my/evaluate-nearest-src-block ()
  (interactive)
  (save-excursion
    (org-back-to-heading)
    (my/forward-to-src-block)
    (org-ctrl-c-ctrl-c)))

(defun my/smart-copy-nearest-src-block ()
  (interactive)
  (save-excursion
    (org-back-to-heading)
    (my/forward-to-src-block)
    (my-smart-copy)))

(defun my/copy-nearest-src-block-results ()
  (interactive)
  (save-excursion
    (org-back-to-heading)
    (my/forward-to-src-block)
    (org-babel-open-src-block-result)
    (switch-to-buffer "*Org Babel Results*")
    (mark-whole-buffer)
    (copy-region-as-kill nil nil t)
    (delete-window)))

(defun my/name-or-rename-nearest-src-block ()
  (interactive)
  (save-excursion
    (org-back-to-heading)
    (my/forward-to-src-block)
    (let* ((current-name (my/src-block-name))
           (new-name (read-string "Name: " current-name)))
      (if current-name
          (my/rename-src-block new-name)
        (my/name-src-block new-name)))))

(defun my/name-src-block (name)
  (save-excursion
    (org-babel-goto-src-block-head)
    (open-line 1)
    (insert (format "#+name: %s" name))))

(defun my/rename-src-block (name)
  (save-excursion
    (org-babel-goto-src-block-head)
    (previous-line)
    (move-beginning-of-line nil)
    (kill-line)
    (insert (format "#+name: %s" name))))

(defun my/src-block-name ()
  (save-excursion
    (org-babel-goto-src-block-head)
    (if (= (line-number-at-pos) 1)
        nil
      (previous-line)
      (let ((current-line (thing-at-point 'line t)))
        (if (string-match (rx "#+name: " (group (zero-or-more not-newline))) current-line)
            (match-string-no-properties 1 current-line)
          nil)))))

(defun my/goto-src-block-beginning ()
  (org-babel-goto-src-block-head)
  (when (not (= (line-number-at-pos) 1))
    (previous-line)
    (move-beginning-of-line nil)
    (let ((current-line (thing-at-point 'line t)))
      (when (not (string-match (rx "#+name: ") current-line))
        (next-line)))))

(defun my/goto-src-block-end ()
  (let ((name (my/src-block-name)))
    (when name (org-babel-goto-named-result name))
    (goto-char (org-babel-result-end))))

(defun my/select-src-block ()
  (my/goto-src-block-beginning)
  (set-mark-command nil)
  (goto-char (org-babel-result-end)))

(defun my/copy-src-block ()
  (interactive)
  (save-excursion
    (my/select-src-block)
    (kill-ring-save nil nil t)))

(defun my/kill-src-block ()
  (interactive)
  (my/select-src-block)
  (kill-region nil nil t))

(defun my/duplicate-src-block ()
  (interactive)
  (let ((name (my/src-block-name)))
    (my/copy-src-block)
    (my/goto-src-block-end)
    (newline)
    (yank)
    (previous-line)
    (org-babel-goto-src-block-head)
    (when name
      (my/rename-src-block (format "%s-copy" name)))))

(defun my/edit-nearest-src-block ()
  (interactive)
  (save-excursion
    (org-back-to-heading)
    (my/forward-to-src-block)
    (org-edit-special)))

(defun my/clear-nearest-src-block-results ()
  (interactive)
  (save-excursion
    (org-back-to-heading)
    (my/forward-to-src-block)
    (org-babel-remove-result-one-or-many nil)))

(defun my/clear-all-src-block-results ()
  (interactive)
  (when (y-or-n-p "Really clear results in the whole buffer?")
    (setq current-prefix-arg '(4))
    (call-interactively 'org-babel-remove-result-one-or-many nil)))

(defun my/edit-nearest-src-block-args ()
  (interactive)
  (save-excursion
    (org-back-to-heading)
    (my/forward-to-src-block)
    (let ((beg (point)))
      (forward-sexp 2)
      (let* ((block-beg (buffer-substring beg (point)))
             (current-args (string-trim (buffer-substring (point) (my/point-at-end-of-line))))
             (new-args (string-trim (read-string "New args: " current-args))))
        (move-beginning-of-line nil)
        (kill-line)
        (insert (format "%s %s" block-beg new-args))))))

(defun arttsu-temporary-buffer ()
  (interactive)
  (switch-to-buffer-other-window (make-temp-name "temp-")))

(defun my-copy-src-message (src)
  (let ((lines (split-string src "\n")))
    (if (> (length lines) 2)
        (concat "Copied:\n" (nth 0 lines) "\n" (nth 1 lines) "\n  ...")
        (concat "Copied:\n" src))))

(defun my-copy-src (context)
  (let* ((info (org-babel-lob-get-info context))
         (info (if info (copy-tree info) (org-babel-get-src-block-info)))
         (src (nth 1 info)))
    (progn
      (kill-new src)
      (message (my-copy-src-message src)))))

(defun my-copy-link (context)
  (let* ((plist (nth 1 context))
         (raw-link (plist-get plist ':raw-link)))
    (progn
      (kill-new raw-link)
      (message (concat "Copied:\n" raw-link)))))

(defun my-smart-copy ()
  (interactive)
  (let* ((context (org-element-context))
         (context-type (nth 0 context)))
    (cond ((eq context-type 'src-block) (my-copy-src context))
          ((eq context-type 'link) (my-copy-link context))
          (t (message "Nothing to copy")))))

(global-set-key (kbd "C-c y") #'my-smart-copy)

(defun my/insert-src-block-within-heading ()
  (open-line 0)
  (org-insert-structure-template "src")
  (let ((lang (completing-read "Language: " '("elisp" "shell" "sql" "restclient" "python" "ruby" "scala"))))
    (insert lang))
  (previous-line)
  (move-end-of-line nil))

(defun my/do-insert-src-heading ()
  (let ((title (read-string "Title: " "Block")))
    (insert title))
  (my/insert-src-block-within-heading))

(defun my/insert-src-heading ()
  (interactive)
  (if (org-before-first-heading-p)
      (org-insert-heading)
    (org-insert-heading-respect-content))
  (my/do-insert-src-heading))

(defun my/insert-src-heading-before ()
  (interactive)
  (if (org-before-first-heading-p)
      (org-insert-heading)
    (org-back-to-heading)
    (org-insert-heading))
  (my/do-insert-src-heading))

(defun my/duplicate-src-heading ()
  (interactive)
  (org-copy-subtree)
  (org-back-to-heading)
  (org-yank)
  (when org-yank-folded-subtrees
    (org-backward-element)
    (org-cycle)
    (org-forward-element))
  (move-end-of-line nil)
  (insert " (copy)"))

(defun my/duplicate-src-heading-before ()
  (interactive)
  (org-copy-subtree)
  (org-back-to-heading)
  (org-yank)
  (org-backward-element)
  (when org-yank-folded-subtrees
    (org-cycle))
  (move-end-of-line nil)
  (insert " (copy)"))

(defun my/edit-src-block-results ()
  (interactive)
  (search-forward "#+RESULTS:")
  (search-forward "#+BEGIN_SRC")
  (org-edit-special))

(defun my/insert-heading-before ()
  (interactive)
  (org-back-to-heading)
  (org-insert-heading))

(defun my/rename-heading ()
  (interactive)
  (save-excursion
    (org-back-to-heading)
    (let* ((current-title (org-entry-get nil "ITEM"))
           (new-title (read-string "New title: " current-title)))
      (replace-string current-title
                      new-title
                      nil
                      (point)
                      (my/point-at-end-of-line)))))

(defun my/seek-to-heading-content ()
  (let ((line-num-before (line-number-at-pos)))
    (forward-line)
    (cond ((= line-num-before (line-number-at-pos)) (crux-smart-open-line nil))
          ((org-at-heading-p) (crux-smart-open-line-above))
          ((org-at-planning-p) (my/seek-to-heading-content))
          ((org-at-drawer-p) (my/seek-to-heading-content))
          (t nil))))

(defun my/edit-heading-content ()
  (interactive)
  (org-back-to-heading)
  (org-show-entry)
  (my/seek-to-heading-content))

(defun my/mark-as (todo-state)
  (save-excursion
    (org-back-to-heading)
    (org-todo todo-state)))

(defun my/mark-as-todo ()
  (interactive)
  (my/mark-as "TODO"))

(defun my/mark-as-done ()
  (interactive)
  (my/mark-as "DONE"))

(defun my/jump-to-first-heading ()
  (interactive)
  (beginning-of-buffer)
  (when (not (org-at-heading-p))
    (org-next-visible-heading 1)))

(defun my/jump-to-last-heading ()
  (interactive)
  (end-of-buffer)
  (org-back-to-heading))

(defun my/goto-charseq-end ()
  (let ((line-end (save-excursion (end-of-line) (point))))
    (condition-case nil
        (progn
          (re-search-forward (rx (or whitespace "(" ")" "[" "]" "{" "}" "\"" "'" "`" ";" "," "=" "|")) line-end)
          (backward-char))
      (error (end-of-line)))))

(defun my/copy-charseq ()
  (interactive)
  (set-mark-command nil)
  (my/goto-charseq-end)
  (setq last-command nil) ;; never append to the last kill
  (copy-region-as-kill nil nil t))

(defun my/avy-action-copy-charseq (point)
  (save-excursion
    (goto-char point)
    (my/copy-charseq))
  (select-window (cdr (ring-ref avy-ring 0)))
  t)

(defun my/avy-yank ()
  (if (derived-mode-p 'vterm-mode)
      (vterm-yank)
    (yank)))

(defun my/avy-action-yank-charseq (point)
  (save-excursion
    (goto-char point)
    (my/copy-charseq))
  (select-window (cdr (ring-ref avy-ring 0)))
  (my/avy-yank)
  t)

(defun my/avy-action-yank-line (point)
  (save-excursion
    (goto-char point)
    (set-mark-command nil)
    (end-of-line)
    (setq last-command nil) ;; never append to the last kill
    (copy-region-as-kill nil nil t))
  (select-window (cdr (ring-ref avy-ring 0)))
  (my/avy-yank)
  t)

(defun my/avy-action-embark (point)
  (unwind-protect
    (goto-char point)
    (embark-act))
  t)

(defun my/avy-action-embark-dwim (point)
  (unwind-protect
    (goto-char point)
    (embark-dwim))
  t)

(defun my/back-to-sexp ()
  (interactive)
  (let ((current-sexp (thing-at-point 'sexp)))
    (if current-sexp
        (let ((current-point (point)))
          (backward-sexp)
          (unless (string= (thing-at-point 'sexp) current-sexp)
            (goto-char current-point)))
      (backward-sexp))))

(defun my/jump-upto-sexp ()
  (interactive)
  (my/back-to-sexp)
  (forward-sexp)
  (forward-sexp)
  (backward-sexp))

(defun my/jump-back-upto-sexp ()
  (interactive)
  (my/back-to-sexp)
  (backward-sexp)
  (forward-sexp))

(defun my/kill-upto-sexp ()
  (interactive)
  (let ((current-point (point))
        (before-current-word (save-excursion
                               (my/back-to-sexp)
                               (point)))
        (before-next-word (save-excursion
                            (my/jump-upto-sexp)
                            (point))))
    (unless (= before-current-word before-next-word)
      (kill-region current-point before-next-word))))

(defun my/kill-back-upto-sexp ()
  (interactive)
  (let ((current-point (point))
        (after-current-sexp (save-excursion
                              (my/back-to-sexp)
                              (forward-sexp)
                              (point)))
        (after-previous-sexp (save-excursion
                               (my/jump-back-upto-sexp)
                               (point))))
    (unless (= after-current-sexp after-previous-sexp)
      (kill-region after-previous-sexp current-point))))

(defun my/back-to-word ()
  (interactive)
  (let ((current-word (thing-at-point 'word)))
    (if current-word
        (let ((current-point (point)))
          (backward-word)
          (unless (string= (thing-at-point 'word) current-word)
            (goto-char current-point)))
      (backward-word))))

(defun my/jump-upto-word ()
  (interactive)
  (my/back-to-word)
  (forward-word)
  (forward-word)
  (backward-word))

(defun my/jump-back-upto-word ()
  (interactive)
  (my/back-to-word)
  (backward-word)
  (forward-word))

(defun my/kill-upto-word ()
  (interactive)
  (let ((current-point (point))
        (before-current-word (save-excursion
                               (my/back-to-word)
                               (point)))
        (before-next-word (save-excursion
                            (my/jump-upto-word)
                            (point))))
    (unless (= before-current-word before-next-word)
      (kill-region current-point before-next-word))))

(defun my/kill-back-upto-word ()
  (interactive)
  (let ((current-point (point))
        (after-current-word (save-excursion
                              (my/back-to-word)
                              (forward-word)
                              (point)))
        (after-previous-word (save-excursion
                               (my/jump-back-upto-word)
                               (point))))
    (unless (= after-current-word after-previous-word)
      (kill-region after-previous-word current-point))))

(defun my/do-switch-project (find-dir-fn)
  (let ((dir (project-prompt-project-dir)))
    (funcall find-dir-fn dir))
  (let ((name (-last-item (butlast (s-split "/" (project-root (project-current)))))))
    (tab-rename name)))

(defun my/switch-project ()
  (interactive)
  (my/do-switch-project 'find-file))

(defun my/switch-project-other-tab ()
  (interactive)
  (my/do-switch-project 'find-file-other-tab))

(defun my/convert-timestamp-to-datetime (timestamp)
  (format-time-string "%Y-%m-%d %H:%M:%S" (seconds-to-time (string-to-number timestamp)) t))

(defun my-timestamp-to-datetime ()
  (interactive)
  (let* ((timestamp (read-string "Timestamp: "))
         (datetime (my/convert-timestamp-to-datetime timestamp)))
    (kill-new datetime)
    (message datetime)))

(defun my-datetime-to-timestamp ()
  (interactive)
  (let* ((datetime (read-string "Datetime: "))
         (time (date-to-time datetime))
         (timestamp (number-to-string (time-to-seconds time))))
    (kill-new timestamp)
    (message timestamp)))

(defun my/zoom-frame (&optional n frame amt)
  "Increase the default size of text by AMT inside FRAME N times.
  N can be given as a prefix arg.
  AMT will default to 10.
  FRAME will default the selected frame."
  (interactive "p")
  (let ((frame (or frame (selected-frame)))
        (height (+ (face-attribute 'default :height frame) (* n (or amt 10)))))
    (set-face-attribute 'default frame :height height)
    (when (called-interactively-p)
      (message "Set frame's default text height to %d." height))))

(defun my/zoom-frame-out (&optional n frame amt)
  "Call `my/zoom-frame' with -N."
  (interactive "p")
  (my/zoom-frame (- n) frame amt))

(defun my/zoom-frame-default ()
  (interactive)
  (set-face-attribute 'default (selected-frame) :height my/font-height))

(defconst my/bagel-radio-url "https://onlineradiobox.com/us/bagel/playlist/")

(defun my/onlineradio-bagel-schedule ()
  (interactive)
  (my/onlineradio-schedule "Bagel Radio" my/bagel-radio-url))

(defun my/onlineradio-schedule (name url)
  (interactive)
  (let ((schedule (with-current-buffer (url-retrieve-synchronously url)
                    (my/onlineradio-extract-schedule '()))))
    (with-output-to-temp-buffer (format "*%s*" name)
      (dolist (pair schedule)
        (let ((time (nth 0 pair))
              (song (nth 1 pair)))
          (princ (format "%s\n      %s\n" (my/decode-entities time) (my/decode-entities song))))))))

(defun my/onlineradio-extract-schedule (schedule)
  (condition-case nil
      (let ((time (my/onlineradio-extract-time))
            (song (my/onlineradio-extract-song)))
        (my/onlineradio-extract-schedule (cons (list time song) schedule)))
    (error (reverse schedule))))

(defun my/onlineradio-extract-time ()
  (search-forward "time--schedule\">")
  (let ((before (point)))
    (iy-go-up-to-char 1 ?<)
    (let ((after (point)))
      (buffer-substring before after))))

(defun my/onlineradio-extract-song ()
  (search-forward "track_history_item")
  (iy-go-to-char 2 ?>)
  (let ((before (point)))
    (iy-go-up-to-char 1 ?<)
    (let ((after (point)))
      (buffer-substring before after))))

(defun my/decode-entities (html)
  (with-temp-buffer
    (save-excursion (insert html))
    (xml-parse-string)))

(use-package lsp-mode
  :hook
  (scala-mode . lsp)
  (python-mode . lsp)
  (ruby-mode . lsp)
  :commands lsp
  :bind
  (:map lsp-mode-map
        ([M-down-mouse-1] . mouse-set-point)
        ([M-mouse-1] . lsp-find-definition)
        ([M-mouse-3] . xref-go-back)
        ("<f4>" . lsp-rename)))

(use-package lsp-ui)

(use-package lsp-metals
  :after lsp)

(use-package consult-lsp
  :after (consult lsp))

(with-eval-after-load 'hydra
  (defhydra arttsu-programming-hydra (:color blue)
    "Programming\n\n"

    ("l" #'arttsu-lsp-show-log "Show log" :column "LSP")

    ("M" #'smerge-vc-next-conflict "Next conflict" :column "Merge" :color pink)
    ("U" #'smerge-keep-upper "Keep upper" :color pink)
    ("L" #'smerge-keep-lower "Keep lower" :color pink)
    ("A" #'smerge-keep-all "Keep all" :color pink)

    ("d" #'consult-lsp-diagnostics "Diagnostics" :column "Project")

    ("S" #'consult-lsp-symbols "Symbols" :column "Navigation")
    ("r" #'lsp-find-references "Find references")

    ("a" #'lsp-execute-code-action "Code action" :column "Code")
    ("f" #'lsp-format-buffer "Format buffer")
    ("i" #'lsp-organize-imports "Organize imports")

    ("q" #'hydra-keyboard-quit "Quit" :column "")
    ("s" #'my/save-all-buffers "Save all buffers")
    ("<f5>" #'my/cockpit-hydra/body "Cockpit"))

  (define-key prog-mode-map (kbd "<f5>") #'arttsu-programming-hydra/body)

  (with-eval-after-load 'magit
    (define-key magit-mode-map (kbd "<f5>") #'arttsu-programming-hydra/body)))

(defun arttsu-lsp-show-log ()
  (interactive)
  (switch-to-buffer-other-window "*lsp-log*")
  (end-of-buffer nil))

(use-package yasnippet
  :config
  (yas-global-mode +1))

(use-package chruby)

(use-package rspec-mode)

(use-package scala-mode
  :interpreter "scala")

(use-package sbt-mode
  :commands sbt-start sbt-command
  :init
  (setq sbt:program-options '("-Dsbt.supershell=false")))

(use-package clojure-mode
  :config
  (define-clojure-indent
   (match 1)))

(use-package tree-sitter
  :config
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))

(use-package tree-sitter-langs)

(use-package kubel
  :after vterm
  :config
  (kubel-vterm-setup)
  (advice-add 'kubel-exec-vterm-pod :before (lambda () (setq vterm-shell "/bin/bash")))
  (advice-add 'kubel-exec-vterm-pod :after (lambda () (setq vterm-shell my/fish-path)))
  :bind
  (:map kubel-mode-map
        ("n" . next-line)
        ("p" . previous-line)
        ("N" . kubel-set-namespace)
        ("P" . kubel-port-forward-pod)
        ("s" . tabulated-list-sort)))

(defun my/kubel-set-namespace (namespace)
  (require 'cl)
  (flet ((completing-read (&rest args) namespace))
    (kubel-set-namespace)))

(defun my/kubel-set-context (context)
  (require 'cl)
  (flet ((completing-read (&rest args) context))
    (kubel-set-context)))

(use-package project
  :straight nil
  :after (projectile)
  :config
  (add-to-list 'project-switch-commands '(project-dired "Dired" "D") t)
  (add-to-list 'project-switch-commands '(projectile-run-vterm "Vterm" "V") t)
  (add-to-list 'project-switch-commands '(magit-status "Magit" "G") t))

(use-package projectile
  :demand
  :bind
  (("M-<f12>" . #'projectile-run-vterm)
   ("M-<f6>" . #'projectile-ripgrep)))

(use-package rg
  :config
  (rg-enable-default-bindings))

(use-package consult
  :demand)

(add-to-list 'auto-mode-alist '("\\.hql\\'" . sql-mode))
(add-to-list 'auto-mode-alist '("\\.cql\\'" . sql-mode))

(use-package markdown-mode)

(use-package fish-mode)

(use-package kbd-mode
  :straight (kbd-mode :type git :host github :repo "kmonad/kbd-mode")
  :mode "\\.kbd'"
  :interpreter "kbd")

(use-package dired
  :straight nil
  :demand
  :init
  (setq dired-dwim-target t))

(use-package dirvish
  :config
  (dirvish-override-dired-mode)
  :bind
  (("<f7>" . dired-jump)
   :map dirvish-mode-map
   ("<f7>" . dired-jump)))

(use-package pdf-tools)

(use-package magit
  :bind
  (("C-c g" . magit-file-dispatch)))

(defun my/vterm-unbind-function-keys ()
  (local-unset-key (kbd "<f1>"))
  (local-unset-key (kbd "<f2>"))
  (local-unset-key (kbd "<f3>"))
  (local-unset-key (kbd "<f4>"))
  (local-unset-key (kbd "<f5>"))
  (local-unset-key (kbd "<f6>"))
  (local-unset-key (kbd "<f7>"))
  (local-unset-key (kbd "<f8>"))
  (local-unset-key (kbd "<f9>"))
  (local-unset-key (kbd "<f10>"))
  (local-unset-key (kbd "<f11>"))
  (local-unset-key (kbd "<f12>")))

(use-package vterm
  :demand
  :after (dired consult)
  :init
  (setq vterm-module-cmake-args "-DUSE_SYSTEM_LIBVTERM=no")
  (setq vterm-shell my/fish-path)
  :config
  (add-hook 'vterm-mode-hook #'my/vterm-unbind-function-keys))

(use-package restclient
  :config
  (add-to-list 'auto-mode-alist '("\\.http\\'" . restclient-mode)))

(use-package ledger-mode
  :after org
  :init
  (setq ledger-default-date-format "%Y-%m-%d")
  :config
  (ledger-reports-add "bal-this-month" "%(binary) -f %(ledger-file) --invert --period \"this month\" -S amount bal ^Income ^Expenses")
  (ledger-reports-add "bal-last-month" "%(binary) -f %(ledger-file) --invert --period \"last month\" -S amount bal ^Income ^Expenses"))

(use-package eradio
  :init
  (setq eradio-channels '(("DEF CON - soma fm" . "https://somafm.com/defcon256.pls")
                          ("Deep Space One - soma fm" . "https://somafm.com/deepspaceone.pls")
                          ("BAGel Radio" . "http://ais-sa3.cdnstream1.com/2606_128.mp3")
                          ("n5MD Radio" . "https://somafm.com/n5md130.pls")
                          ("Suburbs of Goa" . "https://somafm.com/suburbsofgoa130.pls")
                          ("The Trip" . "https://somafm.com/thetrip130.pls")
                          ("Groove Salad" . "https://somafm.com/groovesalad130.pls")
                          ("WFMU" . "https://wfmu.org/wfmu.pls")
                          ("Rock'N'Soul" . "https://wfmu.org/wfmu_rock.pls")
                          ("Give The Drummer Radio" . "https://wfmu.org/wfmu_drummer.pls")))
  (setq eradio-player '("mpv" "--no-video" "--no-terminal"))
  :bind
  (("C-c r p" . #'eradio-play)
   ("C-c r s" . #'eradio-stop)
   ("C-c r t" . #'eradio-toggle)))

(defun my-set-xingbox-base-url ()
  (interactive)
  (let ((new-url (read-string "New xingbox URL: ")))
    (save-excursion
      (goto-char 0)
      (search-forward "#+name: xingbox")
      (search-forward "rest")
      (beginning-of-line)
      (kill-line)
      (insert (format "  \"%srest\"" new-url)))))

(defun my/org-capture-inbox () (interactive) (org-capture nil "i"))

(defun my/pop-local-mark ()
  (interactive)
  (setq current-prefix-arg '(4))
  (call-interactively 'set-mark-command))

(defun my/kill-current-buffer ()
  (interactive)
  (kill-buffer (current-buffer)))

(defun my/consult-bookmark-other-window ()
  (interactive)
  (let ((original-buffer (current-buffer)))
    (call-interactively 'consult-bookmark)
    (delete-other-windows)
    (split-window-right)
    (switch-to-buffer original-buffer)
    (other-window 1)))

(defun my/consult-bookmark-other-tab ()
  (interactive)
  (let ((original-buffer (current-buffer))
        (target-buffer (progn
                     (call-interactively 'consult-bookmark)
                     (current-buffer))))
    (switch-to-buffer original-buffer)
    (tab-new)
    (switch-to-buffer target-buffer)))

(defun my/vterm-new-tab ()
  (interactive)
  (tab-new)
  (vterm))

(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)
(global-set-key (kbd "C-c i") #'my/org-capture-inbox)

(global-set-key (kbd "<f1>") #'delete-window)
(global-set-key (kbd "C-<f1>") #'my/kill-current-buffer)
(global-set-key (kbd "M-<f1>") #'delete-other-windows)
(global-set-key (kbd "C-S-<f1>") #'tab-close)

(global-set-key (kbd "<f2>") #'consult-bookmark)
(global-set-key (kbd "C-<f2>") #'my/consult-bookmark-other-window)
(global-set-key (kbd "C-S-<f2>") #'my/consult-bookmark-other-tab)

(global-set-key (kbd "<f3>") #'split-window-right)
(global-set-key (kbd "C-<f3>") #'split-window-below)
(global-set-key (kbd "M-<f3>") #'find-file-other-window)
(global-set-key (kbd "C-M-<f3>") #'switch-to-buffer-other-window)
(global-set-key (kbd "S-<f3>") #'find-file-other-tab)
(global-set-key (kbd "C-S-<f3>") #'switch-to-buffer-other-tab)
(global-set-key (kbd "M-S-<f3>") #'tab-new)

(global-set-key (kbd "<f4>") #'rename-buffer)
(global-set-key (kbd "C-S-<f4>") #'tab-rename)

(global-set-key (kbd "<f6>") #'consult-ripgrep)

(global-set-key (kbd "<f8>") #'find-file)
(global-set-key (kbd "C-<f8>") #'consult-buffer)
(global-set-key (kbd "M-<f8>") #'project-find-file)
(global-set-key (kbd "C-M-<f8>") #'consult-project-buffer)
(global-set-key (kbd "C-S-<f8>") #'tab-switch)

(global-set-key (kbd "<f9>") #'previous-buffer)
(global-set-key (kbd "C-<f9>") #'next-buffer)
(global-set-key (kbd "M-<f9>") #'my/pop-local-mark)
(global-set-key (kbd "C-M-<f9>") #'pop-global-mark)
(global-set-key (kbd "C-S-<f9>") #'tab-bar-history-back)

(global-set-key (kbd "<f11>") #'my/switch-project)
(global-set-key (kbd "C-S-<f11>") #'my/switch-project-other-tab)

(global-set-key (kbd "<f12>") #'vterm)
(global-set-key (kbd "C-<f12>") #'vterm-other-window)
(global-set-key (kbd "C-S-<f12>") #'my/vterm-new-tab)

(global-set-key (kbd "C-M-s") #'consult-line)

(define-key org-mode-map (kbd "C-:") #'avy-org-goto-heading-timer)
(define-key org-mode-map (kbd "C-S-s") #'consult-org-heading)

(global-set-key (kbd "C-c j s") #'my/jump-upto-sexp)
(global-set-key (kbd "C-c j S") #'my/jump-back-upto-sexp)
(global-set-key (kbd "C-c k s") #'my/kill-upto-sexp)
(global-set-key (kbd "C-c k S") #'my/kill-back-upto-sexp)

(global-set-key (kbd "C-c j w") #'my/jump-upto-word)
(global-set-key (kbd "C-c j W") #'my/jump-back-upto-word)
(global-set-key (kbd "C-c k w") #'my/kill-upto-word)
(global-set-key (kbd "C-c k W") #'my/kill-back-upto-word)

(with-eval-after-load 'smartparens
  (define-key smartparens-mode-map (kbd "C-c k u") #'sp-unwrap-sexp)
  (define-key smartparens-mode-map (kbd "M-a") #'sp-beginning-of-sexp)
  (define-key smartparens-mode-map (kbd "M-e") #'sp-end-of-sexp)
  (define-key smartparens-mode-map (kbd "C-c {") #'sp-backward-down-sexp)
  (define-key smartparens-mode-map (kbd "C-M-u") #'sp-up-sexp)
  (define-key smartparens-mode-map (kbd "C-c k k") #'sp-kill-hybrid-sexp)
  (define-key smartparens-strict-mode-map (kbd "C-c k u") #'sp-unwrap-sexp)
  (define-key smartparens-strict-mode-map (kbd "M-a") #'sp-beginning-of-sexp)
  (define-key smartparens-strict-mode-map (kbd "M-e") #'sp-end-of-sexp)
  (define-key smartparens-strict-mode-map (kbd "M-j") #'sp-beginning-of-next-sexp)
  (define-key smartparens-strict-mode-map (kbd "M-k") #'sp-beginning-of-previous-sexp)
  (define-key smartparens-strict-mode-map (kbd "C-c {") #'sp-backward-down-sexp)
  (define-key smartparens-strict-mode-map (kbd "C-M-u") #'sp-up-sexp)
  (define-key smartparens-strict-mode-map (kbd "C-c k k") #'sp-kill-hybrid-sexp))

(defun my/open-scratch ()
  (interactive)
  (switch-to-buffer-other-window "*scratch*"))

(defhydra my/cockpit-hydra (:color blue :foreign-keys warn)
  "Cockpit\n\n"

  ("s" #'my/save-all-buffers "Save all buffers" :column "Files/buffers")
  ("S" #'super-save-mode "Toggle autosave")

  ("R" #'project-query-replace-regexp "Replace" :column "Project")

  ("n" #'my/copy-charseq "Copy charseq" :column "Quick Actions")

  ("<f1>" #'my/open-scratch "Scratch" :column "Buffers")

  ("W" #'transpose-frame "Transpose" :color pink :column "Windows")

  ("T" #'modus-themes-toggle "Toggle theme" :column "Appearance")

  ("+" #'my/zoom-frame "In" :color pink :column "Zoom")
  ("-" #'my/zoom-frame-out "Out" :color pink)
  ("0" #'my/zoom-frame-default "Default" :color pink)

  ("l" #'org-store-link "Store link" :color blue :column "Org")

  ("q" #'hydra-keyboard-quit "Quit" :column ""))

(global-set-key (kbd "<f5>") #'my/cockpit-hydra/body)

(defhydra my/notes-hydra (:color blue :foreign-keys warn)
  "Notes\n\n"

  ("d" #'notdeft "List" :column "Deft")
  ("n" #'notdeft-new-file-named "New")
  ("r" #'notdeft-reindex "Reindex")

  ("s" #'notdeft-move-into-subdir "Move into subdir" :column "Deft Ops")
  ("m" #'notdeft-rename-file "Rename")
  ("k" #'notdeft-delete-file "Delete")

  ("l" #'org-roam-buffer-toggle "Backlinks" :column "Zettelkasten")
  ("f" #'org-roam-node-find "Find node")
  ("i" #'org-roam-node-insert "Insert node")

  ("q" #'hydra-keyboard-quit "Quit" :column ""))

(global-set-key (kbd "C-c n") #'my/notes-hydra/body)

(defhydra my/org-hydra (:color pink :foreign-keys warn)
  "Org\n\n"

  ("j" #'org-next-visible-heading "Next" :column "Movement")
  ("J" #'org-forward-heading-same-level "Forward")
  ("k" #'org-previous-visible-heading "Previous")
  ("K" #'org-backward-heading-same-level "Backward")

  ("h" #'org-up-element "Up" :column "Movement (2)")
  ("l" #'org-down-element "Down")
  ("s" #'consult-org-heading "Search")
  (";" #'avy-org-goto-heading-timer "Goto")
  ("<" #'my/jump-to-first-heading "First heading")
  (">" #'my/jump-to-last-heading "Last heading")

  ("<tab>" #'org-cycle "Cycle" :column "Visibility")
  ("S-<tab>" #'org-shifttab "Cycle all")
  ("C-l" #'recenter-top-bottom "Recenter")
  ("v" #'scroll-up-command "Scroll down")
  ("V" #'scroll-down-command "Scroll up")
  ("I" #'org-toggle-inline-images "Toggle images")
  ("N" #'org-narrow-to-subtree "Narrow")
  ("E" #'widen "Widen")

  ("T" #'org-set-tags-command "Set tags" :column "Heading Ops")
  ("tt" #'my/mark-as-todo "Todo")
  ("td" #'my/mark-as-done "Done")
  ("S" #'org-schedule "Schedule")
  ("D" #'org-schedule "Deadline")

  ("w" #'org-refile "Refile" :column "Heading Ops (2)")
  ("r" #'my/rename-heading "Rename")
  ("A" #'org-archive-subtree-default "Archive")
  ("W" #'org-cut-subtree "Cut")
  ("M-w" #'org-copy-subtree "Copy")
  ("y" #'org-yank "Yank")

  ("M-H" #'org-metaleft "Demote" :column "Heading Ops (3)")
  ("M-h" #'org-shiftmetaleft "Demote tree")
  ("M-L" #'org-metaright "Promote")
  ("M-l" #'org-shiftmetaright "Promote tree")
  ("M-j" #'org-metadown "Move down")
  ("M-k" #'org-metaup "Move up")

  ("b" #'my/insert-src-heading "Insert" :column "Src Blocks")
  ("B" #'my/insert-src-heading-before "Insert before")
  ("M-b" #'my/duplicate-src-heading "Duplicate")
  ("M-B" #'my/duplicate-src-heading-before "Duplicate before")

  ("n" #'my/name-or-rename-nearest-src-block "Name or rename" :column "Src Blocks (2)")
  ("e" #'my/evaluate-nearest-src-block "Evaluate")
  ("x" #'my/clear-nearest-src-block-results "Clear results")
  ("X" #'my/clear-all-src-block-results "Clear all results")
  ("M-'" #'my/edit-nearest-src-block-args "Edit args")
  ("R" #'my/edit-src-block-results "Edit results" :color blue)

  ("q" #'hydra-keyboard-quit "Quit" :color blue :column "")
  ("i" #'my/edit-heading-content "Edit heading content" :color blue)
  ("M-<return>" #'my/insert-heading-before "Insert heading before" :color blue)
  ("C-<return>" #'org-insert-heading-respect-content "Insert heading" :color blue)
  ("'" #'my/edit-nearest-src-block "Edit src block" :color blue)
  ("c" #'my/smart-copy-nearest-src-block "Copy src block" :color blue)
  ("M-c" #'my/copy-nearest-src-block-results "Copy src block results" :color blue)
  ("RET" #'org-return "Insert newline")
  ("<f5>" #'my/cockpit-hydra/body "Cockpit" :color blue))

(define-key org-mode-map (kbd "<f5>") #'my/org-hydra/body)

(defhydra my/line-region-ops-hydra (:color blue :foreign-keys warn)
  "Line/region operations\n\n"

  ("c" #'avy-copy-line "Copy line" :column "Line ops")
  ("m" #'avy-move-line "Move line")
  ("k" #'avy-kill-whole-line "Kill line")
  ("s" #'avy-kill-ring-save-whole-line "Save line")

  ("C" #'avy-copy-region "Copy region" :column "Region ops")
  ("M" #'avy-move-region "Move region")
  ("K" #'avy-kill-region "Kill region")
  ("S" #'avy-kill-ring-save-region "Save region")

  ("d" #'crux-duplicate-current-line-or-region "Duplicate line or region" :column "Duplication")
  ("D" #'crux-duplicate-and-comment-current-line-or-region "Duplicate and comment line or region")

  ("q" #'hydra-keyboard-quit "Quit" :color blue :column ""))

(global-set-key (kbd "C-M-;") #'my/line-region-ops-hydra/body)
