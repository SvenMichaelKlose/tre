(fn js-argument-filter (x)
  (?  (& (sharp-quote-symbol? x)
         (global-funinfo-var *funinfo* .x.))
     .x.
     x))
