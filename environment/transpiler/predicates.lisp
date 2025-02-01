(progn
  ,@(@ [`(def-head-predicate ,_)]
       '(identity quote backquote quasiquote quasiquote-splice)))

(fn literal-symbol-function? (x)
  (& (function-expr? x)
     (atom .x.)
     (not ..x)))

(fn literal-symbol? (x)
  (| (not x)
     (eq x t)
     (keyword? x)
     (quote? x)))

(fn simple-argument-list? (x)
  (? x
     (notany [| (cons? _)
                (argument-keyword? _)]
             x)
     t))

(fn constant-literal? (x) ;;; TODO Why is ATOM not enough?
  (| (not x)
     (eq t x)
     (number? x)
     (character? x)
     (string? x)
     (array? x)
     (hash-table? x)))
