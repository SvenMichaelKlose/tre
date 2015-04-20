; tré – Copyright (c) 2008–2013,2015 Sven Michael Klose <pixel@copei.de>

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
(define-php-binary userfun_eq "===")
(define-php-binary bit-and "&")
(define-php-binary bit-or "|")
(define-php-binary bit-xor "^")

(define-php-macro identity (x)
  x)

(define-php-macro userfun_cons (x y)
  `("new " ,(obfuscated-symbol-string '__cons)
           " (" ,(php-dollarize x) ", " ,(php-dollarize y) ")"))
