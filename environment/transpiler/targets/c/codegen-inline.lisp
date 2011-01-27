;;;;; TRE to C transpiler
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

;;;; COMPARISON

(define-c-macro %eq (a b)
  `("TREPTR_TRUTH(" ,a " == " ,b ")"))

(define-c-macro %not (x)
  `("(" ,x " == treptr_nil ? treptr_t : treptr_nil)"))

(define-c-macro cons (a d)
  `("_trelist_get (" ,a "," ,d ")"))

(define-c-macro %car (x)
  `("(" ,x " == treptr_nil ? treptr_nil : tre_lists[" ,x "].car)"))

(define-c-macro %cdr (x)
  `("(" ,x " == treptr_nil ? treptr_nil : tre_lists[" ,x "].cdr)"))

(mapcan-macro _
	'((consp "CONS")
	  (atom  "ATOM")
	  (number?  "NUMBER")
	  (stringp  "STRING")
	  (arrayp  "ARRAY")
	  (functionp  "FUNCTION")
	  (builtinp   "BUILTIN"))
  `((define-c-macro ,($ '% _.) (x)
      `(,(+ "TREPTR_TRUTH(TREPTR_IS_" ._.) "(" ,,x "))"))))

;;;; MISCELLANEOUS

(define-c-macro identity (x)
  x)
