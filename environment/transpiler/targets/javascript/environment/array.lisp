;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(dont-obfuscate constructor)

(defvar *%array-constructor* (make-array).constructor)

(defun array? (x)
  (when x
    (eq *%array-constructor* x.constructor)))

(dont-obfuscate push)

(defun list-array (x)
  (let a (make-array)
    (dolist (i x a)
      (a.push i))))

(defun array-list (x &optional (n 0))
  (when (and x (%%%< n x.length))
    (cons (aref x n)
		  (array-list x (1+ n)))))

(dont-obfuscate *array)

(dont-inline array-find)

(defun array-find (arr obj)
  (declare type array arr)
  (%setq nil (%transpiler-native "return " arr ".indexOf (" obj ") != -1;"))
  nil)
