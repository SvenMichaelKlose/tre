(progn
  ,@(@ [`(def-head-predicate ,_)]
       '(identity quote backquote quasiquote quasiquote-splice)))

(fn sharp-quote? (x)
  (& (function-expr? x)
     (atom .x.)
     (not ..x)))

(fn literal? (x)
  (| (bool? x)
     (number? x)
     (character? x)
     (string? x)
     (array? x)
     (hash-table? x)))
