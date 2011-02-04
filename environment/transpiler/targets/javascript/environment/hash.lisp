;;;;; TRE to ECMAScript transpiler
;;;;; Copyright (c) 2009-2011 Sven Klose <pixel@copei.de>

(defun hash-table? (x)
  (and (objectp x)
       (undefined? x.__class)))

(defun hash-assoc (x)
  (let lst nil
    (maphash #'((k v)
				  (acons! k v lst))
         	 x)
    (reverse lst)))

(defun hash-merge (a b)
  (declare type (hash-table nil) a b)
  (when (or a b)
    (unless a
      (setf a (make-hash-table)))
    (%transpiler-native "for (var " k " in " b ") " a "[" k "]=" b "[" k "];")
    a))
