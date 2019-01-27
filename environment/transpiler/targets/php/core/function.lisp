(fn function? (x)
  (?
    (is_a x "__closure") (function_exists x.n)
    (string? x)          (function_exists x)))

(fn builtin? (x))

(fn function-bytecode (x))
(fn function-source (x))
