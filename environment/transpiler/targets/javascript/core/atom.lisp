(js-type-predicate function? "function")
(js-type-predicate object? "object")

(fn pure-object? (x)
  (& (object? x)
     (not (defined? x.__tre-test))
     (not (defined? x.__class))))

(fn builtin? (x))
