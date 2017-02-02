(mapcar-macro x '(identity quote backquote quasiquote quasiquote-splice)
  `(def-head-predicate ,x))

(fn literal-function? (x)
  (& (cons? x)
     (eq 'function x.)
     (atom .x.)
     (not ..x)))

(fn global-literal-function? (x)
  (& (literal-function? x)
     (not (funinfo-find *funinfo* .x.))))

(fn simple-argument-list? (x)
  (? x
     (not (some [| (cons? _)
                   (argument-keyword? _)]
                x))
	 t))

(fn constant-literal? (x)
  (| (not x)
     (eq t x)
     (number? x)
     (character? x)
     (string? x)
     (array? x)
     (hash-table? x)))

(fn codegen-expr? (x)
  (& (cons? x)
     (| (string? x.)
        (in? x. '%%native '%%string)
        (expander-has-macro? (codegen-expander) x.))))
