;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

;(define-php-binary - "-")
(define-php-binary / "/")
(define-php-binary * "*")
;(define-php-binary == "==") ; XXX these will give us trouble with chars.
;(define-php-binary < "<")
;(define-php-binary > ">")
(define-php-binary string== "==")
(define-php-binary >> ">>")
(define-php-binary << "<<")
(define-php-binary mod "%")
(define-php-binary logxor "^")
(define-php-binary userfun_eq "===")
(define-php-binary bit-and "&")
(define-php-binary bit-or "|")

(define-php-macro identity (x)
  x)

(define-php-macro userfun_cons (x y)
  `("new " ,(transpiler-obfuscated-symbol-string *current-transpiler* '__cons)
               "(" ,(php-dollarize x) "," ,(php-dollarize y) ")"))
