;;;;; tré - Copyright (c) 2008-2012 Sven Michael Klose <pixel@copei.de>

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
