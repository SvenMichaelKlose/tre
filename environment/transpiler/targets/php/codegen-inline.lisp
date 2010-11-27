;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Extra code-generating macros to avoid costly function calls.

(define-php-binary + "+")
(define-php-binary string-concat "+")
(define-php-binary - "-")
(define-php-binary / "/")
(define-php-binary * "*")
;(define-php-binary = "==") ; XXX these will give us trouble with chars.
;(define-php-binary < "<")
;(define-php-binary > ">")
(define-php-binary string= "==")
(define-php-binary >> ">>")
(define-php-binary << "<<")
(define-php-binary mod "%")
(define-php-binary logxor "^")
(define-php-binary userfun_eq "===")
(define-php-binary bit-and "&")
(define-php-binary bit-or "|")

(define-php-macro identity (x)
  x)

(define-php-macro car (x)
  `("(" ,x " === null ? null : " ,x "." ,(symbol-name (transpiler-obfuscate-symbol *php-transpiler* '_)) ")"))

(define-php-macro cdr (x)
  `("(" ,x " === null ? null : " ,x "." ,(symbol-name (transpiler-obfuscate-symbol *php-transpiler* '__)) ")"))
