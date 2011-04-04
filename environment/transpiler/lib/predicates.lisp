;;;; TRE compiler
;;;; Copyright (c) 2006-2011 Sven Klose <pixel@copei.de>
;;;;
;;;; Miscellaneous predicates

(defun compilable? (x)
  (or (function? x)
      (macrop x)))

(mapcar-macro x
	'(identity quote backquote quasiquote quasiquote-splice)
  `(def-head-predicate ,x))

(defun function-ref-expr? (x)
  (and (cons? x)
       (eq 'FUNCTION x.)
	   (atom .x.)))

(defun atom-function-expr? (x)
  (and (cons? x)
       (eq x. 'function)
	   (atom .x.)
	   .x.))

(defun named-lambda? (x)
  (and (function-expr? x)
	   ..x))

(defun vec-function-expr? (x)
  (and (cons? x)
	   (eq x. 'function)
	   (%vec? .x.)
	   .x.))
