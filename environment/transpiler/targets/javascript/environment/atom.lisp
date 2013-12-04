;;;;; tré – Copyright (c) 2008–2009,2011,2013 Sven Michael Klose <pixel@copei.de>

(declare-cps-exception function? object? builtin?)

(js-type-predicate function? "function")
(js-type-predicate object? "object")

(defun builtin? (x))
