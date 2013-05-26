;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate constructor)

(defvar *js-array-constructor* (make-array).constructor)

(defun aref (a k)
  (%%%aref a k))

(defun =-aref (v a k)
  (%%%=-aref v a k))

(defun array? (x)
  (& x (eq *js-array-constructor* x.constructor)))

(dont-obfuscate push)

(defun list-array (x)
  (alet (make-array)
    (dolist (i x !)
      (!.push i))))

(dont-obfuscate *array)
(dont-inline array-find)

(defun array-find (arr obj)
  (%setq nil (%%native "return " arr ".indexOf (" obj ") != -1;"))
  nil)
