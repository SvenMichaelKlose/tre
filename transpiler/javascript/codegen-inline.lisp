;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Extra code-generating macros to avoid costly function calls.

(define-js-binary + "+")
(define-js-binary string-concat "+")
(define-js-binary - "-")
(define-js-binary / "/")
(define-js-binary * "*")
;(define-js-binary = "==") ; XXX these will give us trouble with chars.
;(define-js-binary < "<")
;(define-js-binary > ">")
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
  `("(" ,x " ? " ,x "." ,(symbol-name (transpiler-obfuscate-symbol *js-transpiler* '_)) " : null)"))

(define-js-macro cdr (x)
  `("(" ,x " ? " ,x "." ,(symbol-name (transpiler-obfuscate-symbol *js-transpiler* '__)) " : null)"))
