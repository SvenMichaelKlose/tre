;;;; TRE compiler
;;;; Copyright (c) 2006-2009 Sven Klose <pixel@copei.de>
;;;;
;;;; Miscellaneous predicates

(defun compilable? (x)
  (or (functionp x)
      (macrop x)))

(mapcar-macro x
	'(quote %quote backquote
	  identity %new
	  %transpiler-native %transpiler-string)
  `(def-head-predicate ,x))

(defun function-ref-expr? (x)
  (and (consp x)
       (eq 'FUNCTION x.)
	   (atom (second x))))
