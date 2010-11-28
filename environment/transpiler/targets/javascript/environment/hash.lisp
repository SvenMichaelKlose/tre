;;;;; TRE to ECMAScript transpiler
;;;;; Copyright (c) 2009-2010 Sven Klose <pixel@copei.de>

(defun hash-table? (x)
  (and (objectp x)
       (undefined? x.__class)))

(defun hash-assoc (x)
  (let lst nil
    (maphash #'((k v)
				  (push! (cons k v) lst))
         	 x)
    (reverse lst)))
