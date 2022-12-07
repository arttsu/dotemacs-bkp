(setq frame-inhibit-implied-resize t)

(if (equal system-type 'darwin)
    (add-to-list 'default-frame-alist '(undecorated-round . t))
  (add-to-list 'default-frame-alist '(undecorated . t)))
