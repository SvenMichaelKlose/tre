;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Extra code-generating macros to avoid costly function calls.

(define-js-binary / "/")
(define-js-binary * "*")

(define-js-binary userfun_integer+ "+")
(define-js-binary userfun_integer- "-")
(define-js-binary userfun_integer/ "/")
(define-js-binary userfun_integer* "*")
(define-js-binary userfun_integer= "==")
(define-js-binary userfun_integer< "<")
(define-js-binary userfun_integer> ">")
(define-js-binary userfun_integer<= "<=")
(define-js-binary userfun_integer>= ">=")

(define-js-binary userfun_string= "==")

;(define-js-binary >> ">>")
;(define-js-binary << "<<")
(define-js-binary mod "%")
;(define-js-binary logxor "^")
(define-js-binary userfun_eq "===")
(define-js-binary bit-and "&")
(define-js-binary bit-or "|")

(define-js-macro userfun_identity (x) x)

(define-js-macro userfun_cons (x y)
  `("new " ,(transpiler-obfuscated-symbol-string *js-transpiler* 'userfun_%cons)
           "(" ,x "," ,y ")"))

(mapcan-macro p
	'((userfun_car _)
	  (userfun_cdr __))
  (let slotname .p.
    `((define-js-macro ,p. (x)
        `("(" ,,x " == null ? null : "
	      ,,x "." ,,(symbol-name
					    (transpiler-obfuscate *js-transpiler*
											  ,(list 'quote slotname)))
	      ")"))
      (define-js-macro ,($ '%%usetf- p.) (v x)
        `(%transpiler-native ,,x "." ,,(symbol-name
										   (transpiler-obfuscate
											   *js-transpiler*
											   ,(list 'quote slotname)))
							 "=" ,,v)))))
