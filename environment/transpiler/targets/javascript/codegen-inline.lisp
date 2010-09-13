;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Extra code-generating macros to avoid costly function calls.

;(define-js-binary userfun_string-concat "+")
(define-js-binary / "/")
(define-js-binary * "*")
;(define-js-binary userfun_string= "==")
;(define-js-binary >> ">>")
;(define-js-binary << "<<")
;(define-js-binary mod "%")
;(define-js-binary logxor "^")
;(define-js-binary _eq "===")
;(define-js-binary bit-and "&")
;(define-js-binary bit-or "|")

;(define-js-macro userfun_identity (x) x)

;(mapcan-macro p
;	'((userfun_car _)
;	  (userfun_cdr __))
;  (let slotname .p.
;    `((define-js-macro ,p. (x)
;        `("(" ,,x " == null ? null : "
;	      ,,x "." ,,(symbol-name
;					    (transpiler-obfuscate *js-transpiler*
;											  ,(list 'quote slotname)))
;	      ")"))
;      (define-js-macro ,($ '%%usetf- p.) (v x)
;        `(%transpiler-native ,,x "." ,,(symbol-name
;										   (transpiler-obfuscate
;											   *js-transpiler*
;											   ,(list 'quote slotname)))
;							 "=" ,,v)))))
