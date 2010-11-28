;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(dont-obfuscate is_array)

(defun arrayp (x)
  (is_array x))

(defun %array-length (x)
  ((%transpiler-native count) x))

(dont-obfuscate array_push)

(defun list-array (x)
  (let a (make-array)
    (dolist (i x a)
      (array_push a i))))

(dont-obfuscate sizeof)

(defun array-list (x &optional (n 0))
  (when (%%%< n (%array-length x))
    (cons (aref x n)
		  (array-list x (1+ n)))))
