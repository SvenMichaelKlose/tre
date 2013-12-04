;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate parse-float parse-int)
(declare-cps-exception parse-float parse-int %number number string-integer number-integer integer?)

(js-type-predicate %number? "number")

(defun number (x)
  (parse-float x 10))

(defun string-integer (x)
  (parse-int x 10))

(dont-obfuscate *math floor)

(defun number-integer (x)
  (*math.floor x))

(defun integer? (x)
  (& (%number? x)
     (%%%== (parse-int x 10) (parse-float x 10))))
