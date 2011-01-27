;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(js-type-predicate %number? "number")

(dont-obfuscate parse-int)

(defun number (x)
  (parse-int x 10))
