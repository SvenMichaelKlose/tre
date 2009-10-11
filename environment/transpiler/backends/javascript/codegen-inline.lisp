;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Extra code-generating macros to avoid costly function calls.

;(define-js-binary + "+")
;(define-js-binary - "-")
(define-js-binary string-concat "+")
(define-js-binary / "/")
(define-js-binary * "*")
(define-js-binary integer+ "+")
(define-js-binary integer- "-")
(define-js-binary integer< "<")
(define-js-binary integer> ">")
(define-js-binary integer<= "<=")
(define-js-binary integer>= ">=")
(define-js-binary string= "==")
(define-js-binary >> ">>")
(define-js-binary << "<<")
(define-js-binary mod "%")
(define-js-binary logxor "^")
(define-js-binary eq "===")
(define-js-binary bit-and "&")
(define-js-binary bit-or "|")

(define-js-macro identity (x)
  x)

(define-js-macro car (x)
  `("(" ,x " === null ? null : " ,x "." ,(symbol-name (transpiler-obfuscate-symbol *js-transpiler* '_)) ")"))

(define-js-macro cdr (x)
  `("(" ,x " === null ? null : " ,x "." ,(symbol-name (transpiler-obfuscate-symbol *js-transpiler* '__)) ")"))

(define-js-macro string-downcase (x) `((%slot-value ,x to-lower-case)))
(define-js-macro string-upcase (x)   `((%slot-value ,x to-upper-case)))

(mapcan-macro _
	`(+ -)
  (let name ($ 'character _)
    `((define-js-macro ,name (&rest x)
	    (let l (length x)
		  (if (= l 2)
              `(,($ '%%% _) (%slot-value ,,x. v)
  		             		(%slot-value ,,.x. v))
			  `(,name ,,@x)))))))
