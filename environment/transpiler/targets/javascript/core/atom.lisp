(js-type-predicate function? "function")
(js-type-predicate object? "object")

(fn assoc-array? (x)
  (& (object? x)
     (not (array? x))
     (not (defined? x.__tre-test))
     (not (defined? x.__class))))

(fn builtin? (x))
