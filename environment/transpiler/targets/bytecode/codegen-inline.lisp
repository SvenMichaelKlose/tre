;;;;; TRE to C transpiler
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

;;;; COMPARISON

(define-bc-macro %eq (&rest x)
  `("TREPTR_TRUTH(" ,(pad x "==") ")"))

(define-bc-macro %not (&rest x)
  `(eq nil ,@x))

(define-bc-macro cons (a d)
  `("_trelist_get (" ,a "," ,d ")"))

(define-bc-macro %car (x)
  `("(" ,x " == treptr_nil ? treptr_nil : tre_lists[" ,x "].car)"))

(define-bc-macro %cdr (x)
  `("(" ,x " == treptr_nil ? treptr_nil : tre_lists[" ,x "].cdr)"))

(mapcan-macro _
	'((cons? "CONS")
	  (atom  "ATOM")
	  (number?  "NUMBER")
	  (string?  "STRING")
	  (array?  "ARRAY")
	  (function?  "FUNCTION")
	  (builtin?   "BUILTIN"))
  `((define-bc-macro ,($ '% _.) (x)
      `(,(+ "TREPTR_TRUTH(TREPTR_IS_" ._.) "(" ,,x "))"))))

;;;; MISCELLANEOUS

(define-bc-macro identity (x)
  x)
