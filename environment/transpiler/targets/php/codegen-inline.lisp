;(def-php-binary - "-")
(def-php-binary / "/")
(def-php-binary * "*")
; TODO: these will give us trouble with chars, if they haven't been
; converted to numbers.
;(def-php-binary == "==")
;(def-php-binary < "<")
;(def-php-binary > ">")
(def-php-binary string== "==")
(def-php-binary >> ">>")
(def-php-binary << "<<")
(def-php-binary mod "%")
(def-php-binary tre_eq "===")
(def-php-binary bit-and "&")
(def-php-binary bit-or "|")
(def-php-binary bit-xor "^")

(def-php-codegen identity (x)
  x)

(def-php-codegen tre_cons (x y)
  `("new " ,(convert-identifier '__cons)
               "(" ,(php-dollarize x) ", " ,(php-dollarize y) ")"))
