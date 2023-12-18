(fn i18n (x)
  (? (object? x)
     (ref x (downcase (symbol-name *language*)))
     x))
