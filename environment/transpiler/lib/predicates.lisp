;;;;; tré – Copyright (c) 2006–2013 Sven Michael Klose <pixel@copei.de>

(mapcar-macro x
	'(identity quote backquote quasiquote quasiquote-splice)
  `(def-head-predicate ,x))

(defun static-symbol-function? (x)
  (& (cons? x)
     (eq 'function x.)
     (atom .x.)
     (not ..x)
     .x.))

(defun simple-argument-list? (x)
  (? x
     (not (some [| (cons? _) (argument-keyword? _)] x))
	 t))
