(fn js-argument-filter (x)
  (?  (& (sharp-quote? x)
         (global-funinfo-var *funinfo* .x.))
     .x.
     x))
