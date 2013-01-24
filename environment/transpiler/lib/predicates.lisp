;;;;; tré – Copyright (c) 2006–2013 Sven Michael Klose <pixel@copei.de>

(mapcar-macro x
	'(identity quote backquote quasiquote quasiquote-splice)
  `(def-head-predicate ,x))

(defun literal-symbol-function? (x)
  (& (cons? x)
     (eq 'function x.)
     (atom .x.)
     (not ..x)))

(defun simple-argument-list? (x)
  (? x
     (not (some [| (cons? _) (argument-keyword? _)] x))
	 t))

(defun constant-literal? (x)
  (| (not x)
     (eq t x)
     (number? x)
     (string? x)
     (array? x)
     (hash-table? x)))
