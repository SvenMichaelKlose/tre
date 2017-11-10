(js-type-predicate function? "function")
(js-type-predicate object? "object")

(fn builtin? (x))

(const +simple-object-constructor+ (%%%make-object).constructor)

(fn simple-object? (x)
  (& (object? x)
     (eq x.constructor +simple-object-constructor+)))
