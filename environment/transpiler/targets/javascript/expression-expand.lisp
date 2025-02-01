(fn js-argument-filter (x)
  (?  (& (literal-symbol-function? x)
         (global-funinfo-var *funinfo* .x.))
     .x.
     x))
