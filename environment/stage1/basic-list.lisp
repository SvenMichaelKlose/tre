;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
;;;;
;;;; Basic list functions.

(%defun nth (i c)
  (cond
    (c (cond
         ((> i 0) (nth (- i 1) (cdr c)))
         (t (car c))))))

(%defun copy-list (c)
  (cond
    (c (cons (car c)
         (copy-list (cdr c))))))
