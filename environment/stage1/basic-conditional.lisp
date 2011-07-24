;;;;; TRE environment
;;;;; Copyright (c) 2005,2008,2011 Sven Klose <pixel@copei.de>

(%defun compiler-and (x)
  (if (cdr x)
      `(if ,(car x)
		   ,(compiler-and (cdr x)))
      (car x)))

(defmacro and (&rest x)
  (compiler-and x))

(%defun compiler-or (x)
  (if (cdr x)
      (let g (gensym)
        `(let ,g ,(car x)
           (if ,g
               ,g
			   ,(compiler-or (cdr x)))))
      (car x)))

(defmacro or (&rest x)
  (compiler-or x))
