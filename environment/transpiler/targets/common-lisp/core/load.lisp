; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defun %load-r (s)
  (when (peek-char s)
    (. (read s)
       (%load-r s))))

(defun %expand (x)
  (alet (quasiquote-expand (tre:macroexpand (dot-expand x)))
    (? (equal x !)
       x
       (%expand !))))

(defbuiltin load (pathname)
  (print-definition `(%load ,pathname))
  (dolist (i (with-input-file s pathname
               (%load-r s)))
    (eval (%expand i))))
