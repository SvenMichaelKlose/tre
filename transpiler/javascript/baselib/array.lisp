;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defun arrayp (x) (instanceof x *array))

(defun list-array (x)
  (let a (make-array)
    (dolist (i x a)
      (a.push i))))

(defun array-list (x &optional (n 0))
  (when (< n x.length)
    (cons (aref x n)
		  (array-list x (1+ n)))))
