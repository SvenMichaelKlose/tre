;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(js-type-predicate %number? "number")

(dont-obfuscate parse-float parse-int)

(defun number (x)
  (parse-float x 10))

(defun string-integer (x)
  (parse-int x 10))
