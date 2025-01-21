(fn i18n (x)
  (? (object? x)
     (ref x (downcase (symbol-name (car (ensure-list *language*)))))
     x))
