;;;;; tré – Copyright (c) 2006–2013 Sven Michael Klose <pixel@copei.de>

(defun compilable? (x)
  (| (function? x)
     (macrop x)))

(mapcar-macro x
	'(identity quote backquote quasiquote quasiquote-splice)
  `(def-head-predicate ,x))

(defun static-symbol-function? (x)
  (& (cons? x)
     (eq 'FUNCTION x.)
     (atom .x.)
     (not ..x)
     .x.))

(defun named-lambda? (x)
  (& (function-expr? x)
     ..x))

(defun vec-function-expr? (x)
  (& (cons? x)
     (eq x. 'function)
     (%vec? .x.)
     .x.))
