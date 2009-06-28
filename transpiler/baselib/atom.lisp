;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(js-type-predicate functionp "function")
(js-type-predicate objectp "object")

(defun atom (x)
  (not (consp x)))

(defun identity (x) x)
