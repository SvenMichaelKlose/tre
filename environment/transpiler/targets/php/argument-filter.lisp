(fn php-expex-add-global (x)
  (funinfo-var-add (global-funinfo) x)
  (adjoin! x (funinfo-globals *funinfo*))
  x)

(fn php-argument-filter (x) ; TODO: PCASE…
  (?
    (character? x)  (php-expex-add-global (php-compiled-char x))
    (quote? x)      (php-expex-add-global (php-compiled-symbol .x.))
    (keyword? x)    (php-expex-add-global (php-compiled-symbol x))
    x))
