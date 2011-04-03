;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(dont-obfuscate is_array)

(defun array? (x)
  (is_array x))

(defun %array-length (x)
  ((%transpiler-native count) x))

(defun array-push (arr x)
  (%setq (%transpiler-native "$" arr "[]") x)
  x)

(defun list-array (x)
  (let a (make-array)
    (dolist (i x a)
      (%setq (%transpiler-native "$" a "[]") i))))

(dont-obfuscate sizeof)

(defun array-list (x &optional (n 0))
  (when (%%%< n (%array-length x))
    (cons (aref x n)
		  (array-list x (1+ n)))))
