(js-type-predicate function? "function")
(js-type-predicate object? "object")

(fn builtin? (x))

(const +simple-object-constructor+ (%make-json-object).constructor)

(fn json-object? (x)
  (& (object? x)
     (eq x.constructor +simple-object-constructor+)))
