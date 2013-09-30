;;;;; tré – Copyright (c) 2006–2013 Sven Michael Klose <pixel@copei.de>

(mapcar-macro x
	'(identity %identity quote backquote quasiquote quasiquote-splice
      %%in-package)
  `(def-head-predicate ,x))

(defun literal-function? (x)
  (& (cons? x)
     (eq 'function x.)
     (atom .x.)
     (not ..x)))

(defun global-literal-function? (x)                                                                                                
  (& (literal-function? x)
     (not (funinfo-var-or-lexical? *funinfo* .x.))))

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
     (string? x)
     (array? x)
     (hash-table? x)))

(defun codegen-expr? (x)
  (& (cons? x)
     (| (string? x.)
        (in? x. '%%native '%%string)
        (expander-has-macro? (transpiler-codegen-expander *transpiler*) x.))))

(defun atom|codegen-expr? (x)
  (| (atom x)
     (codegen-expr? x)))
