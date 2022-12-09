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
  (setq org-todo-keywords '((sequence "TODO(t)"
                                      "NEXT(n)"
                                      "WAITING(w@/!)"
                                      "|"
                                      "DONE(d!)"
                                      "CANCELLED(c@)")))
  (setq org-confirm-babel-evaluate nil)
  (setq org-startup-indented t)
  (setq org-export-copy-to-kill-ring 'if-interactive)
  (setq org-export-with-sub-superscripts '{})
  (setq org-use-sub-superscripts '{})
  (setq org-blank-before-new-entry '((heading . t) (plain-list-item . auto))))

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
          (("~/org/planner/inbox.org") :level . 0))))

(defun my/day-agenda (keys title files)
  `(,keys
    ,title
    ((agenda "" ((org-agenda-span 1)
                 (org-agenda-skip-scheduled-if-done t)
                 (org-agenda-skip-deadline-if-done t)
                 (org-agenda-skip-timestamp-if-done t)))
     (todo "NEXT" ((org-agenda-overriding-header "NEXT")
                   (org-agenda-skip-function '(org-agenda-skip-entry-if 'deadline 'scheduled))))
     (todo "WAITING" ((org-agenda-overriding-header "WAITING")
                      (org-agenda-skip-function '(org-agenda-skip-entry-if 'deadline 'scheduled))))
     (todo "TODO" ((org-agenda-overriding-header "TODO")
                   (org-agenda-skip-function '(org-agenda-skip-entry-if 'deadline 'scheduled))))
     (org-ql-block '(and (level 1) (not (property "PERMANENT")))
                   ((org-ql-block-header "PROJECTS"))))
    ((org-agenda-compact-blocks)
     (org-agenda-files ',files))))

(with-eval-after-load 'org-agenda
  (setq org-agenda-custom-commands (list (my/day-agenda "p" "Personal agenda" '("~/org/planner/personal.org" "~/org/planner/calendar.org"))
                                         (my/day-agenda "w" "Work agenda" '("~/org/planner/work.org")))))

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
  (setq notdeft-new-file-data-function #'my-notdeft-new-file-data)
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

(setq require-final-newline t)

(setq-default indent-tabs-mode nil)

(global-set-key (kbd "M-z") 'zap-up-to-char)

(global-subword-mode)

(use-package smartparens
  :init
  (add-hook 'emacs-lisp-mode-hook #'smartparens-strict-mode)
  (add-hook 'eval-expression-minibuffer-setup-hook #'smartparens-mode)
  (add-hook 'scala-mode-hook #'smartparens-mode)
  (add-hook 'python-mode-hook #'smartparens-mode)
  (add-hook 'sql-mode-hook #'smartparens-mode)
  :config
  (require 'smartparens-config)
  :bind
  (:map smartparens-strict-mode-map
        ("C-<right>" . sp-forward-slurp-sexp)
        ("C-<left>" . sp-backward-slurp-sexp)
        ("M-<right>" . sp-forward-barf-sexp)
        ("M-<left>" . sp-backward-barf-sexp)
        :map smartparens-mode-map
        ("C-<right>" . sp-forward-slurp-sexp)
        ("C-<left>" . sp-backward-slurp-sexp)
        ("M-<right>" . sp-forward-barf-sexp)
        ("M-<left>" . sp-backward-barf-sexp)))

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

(defun my/mark-as-next ()
  (interactive)
  (my/mark-as "NEXT"))

(defun my/mark-as-done ()
  (interactive)
  (my/mark-as "DONE"))

(defun my/mark-as-cancelled ()
  (interactive)
  (my/mark-as "CANCELLED"))

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
          (message "hello")
          (re-search-forward (rx (or whitespace "(" ")" "[" "]" "{" "}" "\"" "'" "`" ";" "," "=")) line-end)
          (backward-char))
      (error (end-of-line)))))

(defun my/copy-charseq ()
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

(defun my/org-capture-inbox () (interactive) (org-capture nil "i"))

(defun my/pop-local-mark ()
  (interactive)
  (setq current-prefix-arg '(4))
  (call-interactively 'set-mark-command))

(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)
(global-set-key (kbd "C-c i") #'my/org-capture-inbox)

(global-set-key (kbd "<f1>") #'delete-window)
(global-set-key (kbd "C-S-<f1>") #'tab-close)

(global-set-key (kbd "<f2>") #'delete-other-windows)

(global-set-key (kbd "<f3>") #'split-window-right)
(global-set-key (kbd "C-<f3>") #'split-window-below)
(global-set-key (kbd "C-S-<f3>") #'tab-new)

(global-set-key (kbd "<f4>") #'rename-buffer)
(global-set-key (kbd "C-S-<f4>") #'tab-rename)

(global-set-key (kbd "<f8>") #'find-file)
(global-set-key (kbd "M-<f8>") #'project-find-file)
(global-set-key (kbd "C-S-<f8>") #'tab-switch)

(global-set-key (kbd "<f9>") #'previous-buffer)
(global-set-key (kbd "C-<f9>") #'next-buffer)
(global-set-key (kbd "M-<f9>") #'my/pop-local-mark)
(global-set-key (kbd "C-M-<f9>") #'pop-global-mark)
(global-set-key (kbd "C-S-<f9>") #'tab-bar-history-back)

(global-set-key (kbd "<f11>") #'my/switch-project)
(global-set-key (kbd "C-S-<f11>") #'my/switch-project-other-tab)

(global-set-key (kbd "M-/") #'comment-or-uncomment-region)

(define-key org-mode-map (kbd "C-:") #'avy-org-goto-heading-timer)

(defhydra my/cockpit-hydra (:color blue :foreign-keys warn)
  "Cockpit\n\n"

  ("s" #'my/save-all-buffers "Save all buffers" :column "Files/buffers")
  ("S" #'super-save-mode "Toggle autosave")

  ("R" #'project-query-replace-regexp "Replace" :column "Project")

  ("W" #'transpose-frame "Transpose" :color pink :column "Windows")

  ("T" #'modus-themes-toggle "Toggle theme" :column "Appearance")

  ("+" #'my/zoom-frame "In" :color pink :column "Zoom")
  ("-" #'my/zoom-frame-out "Out" :color pink)
  ("0" #'my/zoom-frame-default "Default" :color pink)

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

  ("t" #'org-set-tags-command "Set tags" :column "Heading Ops")
  ("G" #'my/mark-as-done "Done")
  ("N" #'my/mark-as-next "Next")
  ("C" #'my/mark-as-cancelled "Cancelled")
  ("T" #'org-todo "Todo")
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

  ("q" #'hydra-keyboard-quit "Quit" :color blue :column "")
  ("i" #'my/edit-heading-content "Edit heading content" :color blue)
  ("M-<return>" #'my/insert-heading-before "Insert heading before" :color blue)
  ("C-<return>" #'org-insert-heading-respect-content "Insert heading" :color blue)
  ("'" #'my/edit-nearest-src-block "Edit src block" :color blue)
  ("c" #'my/smart-copy-nearest-src-block "Copy src block" :color blue)
  ("RET" #'org-return "Insert newline")
  ("<f5>" #'my/cockpit-hydra/body "Cockpit" :color blue))

(define-key org-mode-map (kbd "<f5>") #'my/org-hydra/body)

(with-eval-after-load 'hydra
  (defun my-lsp-show-log ()
    (interactive)
    (switch-to-buffer "*lsp-log*"))

  (defhydra my-hydra-lsp (:color blue)
    "LSP\n\n"

    ("l" #'my-lsp-show-log "Show log" :column "Project")
    ("d" #'consult-lsp-diagnostics "Diagnostics")

    ("s" #'consult-lsp-file-symbols "File symbols" :column "Navigation")
    ("S" #'consult-lsp-symbols "Symbols")
    ("r" #'lsp-find-references "Find references")

    ("a" #'lsp-execute-code-action "Execute code action" :column "Code")
    ("f" #'lsp-format-buffer "Format buffer")
    ("i" #'lsp-organize-imports "Organize imports"))

  (global-set-key (kbd "C-c l") #'my-hydra-lsp/body))

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

  ("d" #'crux-duplicate-current-line-or-region "Duplicate line or region" :color pink :column "Duplication")
  ("D" #'crux-duplicate-and-comment-current-line-or-region "Duplicate and comment line or region"))

(global-set-key (kbd "C-M-;") #'my/line-region-ops-hydra/body)

(use-package lsp-mode
  :hook
  (scala-mode . lsp)
  (python-mode . lsp)
  (ruby-mode . lsp)
  :commands lsp
  :bind
  (:map lsp-mode-map
        ("C-c j" . lsp-find-definition)
        ([M-down-mouse-1] . mouse-set-point)
        ([M-mouse-1] . lsp-find-definition)
        ("<f4>" . lsp-rename)))

(use-package lsp-ui)

(use-package consult-lsp
  :after (consult lsp))

(use-package flycheck
  :init
  (setq flycheck-global-modes '(not org-mode))
  :config
  (global-flycheck-mode))

(use-package chruby)

(use-package rspec-mode)

(use-package scala-mode
  :interpreter "scala")

(use-package sbt-mode
  :commands sbt-start sbt-command
  :init
  (setq sbt:program-options '("-Dsbt.supershell=false")))

(use-package lsp-metals)

(use-package tree-sitter
  :config
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))

(use-package tree-sitter-langs)

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
  :demand
  :config
  (recentf-mode)
  :bind
  (("<f6>" . #'consult-ripgrep)
   ("C-<f8>" . #'consult-buffer)
   ("C-M-<f8>" . #'consult-project-buffer)
   ("S-<f8>" . #'consult-bookmark)
   ("C-M-s" . #'consult-line)
   :map org-mode-map
   ("C-S-s" . #'consult-org-heading)))

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
  (setq dired-dwim-target t)
  :bind
  (("<f7>" . dired-jump)))

(use-package magit
  :bind
  (("C-c g" . magit-file-dispatch)
   ("C-c b" . magit-blame)))

(use-package vterm
  :demand
  :after (dired consult)
  :init
  (setq vterm-module-cmake-args "-DUSE_SYSTEM_LIBVTERM=no")
  (setq vterm-shell my/fish-path)
  :bind
  (("<f12>" . #'vterm)
   ("C-<f12>" . #'vterm-other-window)
   ("C-S-<f12>" . #'my-vterm-new-tab)
   :map vterm-mode-map
   ("<f1>" . #'delete-window)
   ("C-S-<f1>" . #'tab-close)
   ("<f2>" . #'delete-other-windows)
   ("<f3>" . #'split-window-right)
   ("C-<f3>" . #'split-window-below)
   ("C-S-<f3>" . #'tab-new)
   ("<f4>" . #'rename-buffer)
   ("C-S-<f4>" . #'tab-rename)
   ("<f5>" . #'my/cockpit-hydra/body)
   ("<f6>" . #'consult-ripgrep)
   ("M-<f6>" . #'projectile-ripgrep)
   ("<f7>" . #'dired-jump)
   ("<f8>" . #'find-file)
   ("C-S-<f8>" . #'tab-switch)
   ("<f9>" . #'previous-buffer)
   ("C-<f9>" . #'next-buffer)
   ("C-S-<f9>" . #'tab-bar-history-back)
   ("<f11>" . #'my/switch-project)
   ("<C-S-f11>" . #'my/switch-project-other-tab)
   ("<f12>" . #'vterm)
   ("C-<f12>" . #'vterm-other-window)))

(defun my-vterm-new-tab ()
  (interactive)
  (tab-new)
  (vterm))

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
                          ("BAGel Radio" . "http://ais-sa3.cdnstream1.com/2606_128.mp3")))
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
