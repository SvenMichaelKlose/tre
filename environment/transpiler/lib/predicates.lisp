;;;;; tré – Copyright (c) 2006–2012 Sven Michael Klose <pixel@copei.de>

(defun compilable? (x)
  (| (function? x)
     (macrop x)))

(mapcar-macro x
	'(identity quote backquote quasiquote quasiquote-splice)
  `(def-head-predicate ,x))

(defun function-ref-expr? (x)
  (& (cons? x)
     (eq 'FUNCTION x.)
     (atom .x.)))

(defun atom-function-expr? (x)
  (& (cons? x)
     (eq x. 'function)
     (atom .x.)
     .x.))

(defun named-lambda? (x)
  (& (function-expr? x)
     ..x))

(defun vec-function-expr? (x)
  (& (cons? x)
     (eq x. 'function)
     (%vec? .x.)
     .x.))
