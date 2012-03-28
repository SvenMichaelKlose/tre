;;;;; tré - Copyright (c) 2005,2008,2011-2012 Sven Michael Klose <pixel@copei.de>

(%defun compiler-and (x)
  (? (cdr x)
     `(? ,(car x)
	     ,(compiler-and (cdr x)))
      (car x)))

(defmacro and (&rest x)
  (compiler-and x))

(%defun compiler-or (x)
  (? (cdr x)
     (let g (gensym)
       `(let ,g ,(car x)
          (? ,g
             ,g
		     ,(compiler-or (cdr x)))))
     (car x)))

(defmacro or (&rest x)
  (compiler-or x))
