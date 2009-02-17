;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Extra code-generating macros to avoid costly function calls.

(define-js-binary + "+")
(define-js-binary - "-")
(define-js-binary / "/")
(define-js-binary * "*")
(define-js-binary = "==")
(define-js-binary < "<")
(define-js-binary > ">")
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
  `("(" ,x " ? " ,x "._ : null)"))

(define-js-macro cdr (x)
  `("(" ,x " ? " ,x ".__ : null)"))
