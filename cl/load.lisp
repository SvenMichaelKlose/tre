;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defun %load-r (s)
  (when (tre-parallel:peek-char s)
    (cons (read s)
          (%load-r s))))

(defun %expand (x)
  (alet (quasiquote-expand (tre:macroexpand (dot-expand x)))
    (? (equal x !)
       x
       (%expand !))))

(defun %load (pathname)
  (print `(%load ,pathname))
  (dolist (i (with-input-file s pathname
               (%load-r s)))
    (%eval (%expand i))))
