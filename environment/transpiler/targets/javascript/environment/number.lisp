;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(js-type-predicate %number? "number")

(dont-obfuscate parse-float parse-int)

(defun number (x)
  (parse-float x 10))

(defun string-integer (x)
  (parse-int x 10))

(dont-obfuscate *math floor)

(defun number-integer (x)
  (declare type number x)
  (*math.floor x))

(dont-obfuscate is-na-n)

(defun integer? (x)
  (& (number? x)
     (%%%== (parse-int x 10) (parse-float x 10))))
