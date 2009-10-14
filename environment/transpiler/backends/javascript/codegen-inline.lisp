;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Extra code-generating macros to avoid costly function calls.

;(mapcan-macro _
;    '(+ = < > <= >=)
;  (with (charname ($ 'character _)
;		 op ($ '%%% _))
;    `((define-js-macro ,charname (&rest x)
;	    (if nil ;(= 2 (length x))
;            `(,op (%slot-value ,,x. v)
;                  (%slot-value ,,.x. v))
;		    `(,charname ,,@x)))
;      (define-js-binary ,($ 'integer _) ,(string (if (eq '= _)
;												     '==
;													 _))))))

;(define-js-macro integer- (&rest x)
;  (if (= 1 (length x))
;	  `(%transpiler-native "-" ,x.)
;      `(%%%- ,@x)))

;(define-js-macro character- (&rest x)
;  (if (= 1 (length x))
;	  `(%transpiler-native "-" (%slot-value ,x. v))
;      `(%%%- ,@(mapcar (fn `(%slot-value ,_ v))
;					   x))))

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
  `((define-js-macro ,p. (x)
      `("(" ,,x " === null ? null : "
	    ,,x "." ,,(symbol-name (transpiler-obfuscate-symbol *js-transpiler* ,(list 'quote .p.)))
	    ")"))))

(define-js-macro string-downcase (x) `((%slot-value ,x to-lower-case)))
(define-js-macro string-upcase (x)   `((%slot-value ,x to-upper-case)))
