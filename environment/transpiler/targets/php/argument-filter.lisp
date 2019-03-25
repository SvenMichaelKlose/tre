(fn php-expex-add-global (x)
  (funinfo-var-add (global-funinfo) x)
  (adjoin! x (funinfo-globals *funinfo*))
  x)

(fn php-argument-filter (x)
  (pcase x
    character?  (php-expex-add-global (php-compiled-char x))
    quote?      (php-expex-add-global (php-compiled-symbol .x.))
    keyword?    (php-expex-add-global (php-compiled-symbol x))
    x))
