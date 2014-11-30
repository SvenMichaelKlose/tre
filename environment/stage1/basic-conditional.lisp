;;;;; tré – Copyright (c) 2005,2008,2011–2014 Sven Michael Klose <pixel@copei.de>

(%defun compiler-& (x)
  (? (cdr x)
     `(? ,(car x)
	     ,(compiler-& (cdr x)))
      (car x)))

(defmacro & (&rest x)
  (compiler-& x))

(%defun compiler-| (x)
  (? (cdr x)
     (let g (gensym)
       `(let ,g ,(car x)
          (? ,g
             ,g
		     ,(compiler-| (cdr x)))))
     (car x)))

(defmacro | (&rest x)
  (compiler-| x))
