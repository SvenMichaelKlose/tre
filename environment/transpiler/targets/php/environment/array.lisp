;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(defun arrayp (x)
  (is_array x))

(defun %array-length (x)
  ((%transpiler-native count) x))

(dont-obfuscate push)

(defun list-array (x)
  (let a (make-array)
    (dolist (i x a)
      (a.push i))))

(defun array-list (x &optional (n 0))
  ;(declare type array x) ; fscks up with *h-t-m-l-collection
  (when (%%%< n (array-length x))
    (cons (aref x n)
		  (array-list x (1+ n)))))
