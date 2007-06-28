;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005 Sven Klose <pixel@copei.de>

;; Return T if argument is a cons or NIL (non-atomic/end of list).
(%defun listp (x)
  (cond
    ((consp x) t)
    (t (not x))))
