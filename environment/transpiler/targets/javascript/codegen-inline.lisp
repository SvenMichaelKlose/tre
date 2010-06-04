;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Extra code-generating macros to avoid costly function calls.

(define-js-binary string-concat "+")
(define-js-binary / "/")
(define-js-binary * "*")
(define-js-binary string= "==")
(define-js-binary >> ">>")
(define-js-binary << "<<")
(define-js-binary mod "%")
(define-js-binary logxor "^")
(define-js-binary eq "===")
(define-js-binary bit-and "&")
(define-js-binary bit-or "|")

(define-js-macro identity (x) x)

(mapcan-macro p
	'((car _)
	  (cdr __))
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
