;;;;; tré - Copyright (c) 2008-2012 Sven Michael Klose <pixel@copei.de>

(define-js-macro userfun_cons (x y)
  `("new " ,(transpiler-obfuscated-symbol-string *js-transpiler* 'userfun_%cons)
           "(" ,x "," ,y ")"))

(mapcan-macro p
	'((userfun_car _)
	  (userfun_cdr __))
  (let slotname .p.
    `((define-js-macro ,p. (x)
        `("(" ,,x "==null?null:" ,,x "." ,slotname ")"))
      (define-js-macro ,($ '%%usetf- p.) (v x)
        `(,,x "." ,slotname "=" ,,v)))))
