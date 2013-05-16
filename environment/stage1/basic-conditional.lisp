;;;;; tré – Copyright (c) 2005,2008,2011–2013 Sven Michael Klose <pixel@copei.de>

(early-defun compiler-& (x)
  (? (cdr x)
     `(? ,(car x)
	     ,(compiler-& (cdr x)))
      (car x)))

(defmacro & (&rest x)
  (compiler-& x))

(early-defun compiler-| (x)
  (? (cdr x)
     (let g (gensym)
       `(let ,g ,(car x)
          (? ,g
             ,g
		     ,(compiler-| (cdr x)))))
     (car x)))

(defmacro | (&rest x)
  (compiler-| x))
