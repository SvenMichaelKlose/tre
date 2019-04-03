{,@(@ [`(def-head-predicate ,_)]
      '(identity quote backquote quasiquote quasiquote-splice))}

(fn literal-function? (x)
  (& (cons? x)
     (eq 'function x.)
     (atom .x.)
     (not ..x)))

(fn literal-symbol? (x)
  (| (not x)
     (eq x t)
     (keyword? x)
     (& (cons? x)
        (eq x. 'quote))))

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
