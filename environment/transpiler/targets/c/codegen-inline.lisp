;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

;;;; COMPARISON

(define-c-macro %eq (&rest x)
  `("TREPTR_TRUTH(" ,(pad x "==") ")"))

(define-c-macro %not (&rest x)
  `(eq nil ,@x))

(define-c-macro cons (a d)
  `("_trelist_get (" ,a "," ,d ")"))

(define-c-macro %car (x)
  `("(" ,x " == treptr_nil ? treptr_nil : tre_lists[" ,x "].car)"))

(define-c-macro %cdr (x)
  `("(" ,x " == treptr_nil ? treptr_nil : tre_lists[" ,x "].cdr)"))

(mapcan-macro _
	'((cons? "CONS")
	  (atom  "ATOM")
	  (number?  "NUMBER")
	  (string?  "STRING")
	  (array?  "ARRAY")
	  (builtin?   "BUILTIN"))
  `((define-c-macro ,($ '% _.) (x)
      `(,(+ "TREPTR_TRUTH(TREPTR_IS_" ._.) "(" ,,x "))"))))

(define-c-macro %function? (x)
  `("(TREPTR_TRUTH(TREPTR_IS_FUNCTION(" ,x ") || IS_COMPILED_FUN(" ,x ")))"))

;;;; MISCELLANEOUS

(define-c-macro identity (x)
  x)
