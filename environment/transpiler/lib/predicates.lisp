; tré – Copyright (c) 2006–2015 Sven Michael Klose <pixel@copei.de>

(mapcar-macro x
	'(identity quote backquote quasiquote quasiquote-splice) ; XXX %IDENTITY
  `(def-head-predicate ,x))

(defun literal-function? (x)
  (& (cons? x)
     (eq 'function x.)
     (atom .x.)
     (not ..x)))

(defun global-literal-function? (x)                                                                                                
  (& (literal-function? x)
     (not (funinfo-find *funinfo* .x.))))

(defun simple-argument-list? (x)
  (? x
     (not (some [| (cons? _)
                   (argument-keyword? _)]
                x))
	 t))

(defun constant-literal? (x)
  (| (not x)
     (eq t x)
     (number? x)
     (character? x)
     (string? x)
     (array? x)
     (hash-table? x)))

(defun codegen-expr? (x)
  (& (cons? x)
     (| (string? x.)
        (in? x. '%%native '%%string)
        (expander-has-macro? (codegen-expander) x.))))

(defun atom|codegen-expr? (x)
  (| (atom x)
     (codegen-expr? x)))
