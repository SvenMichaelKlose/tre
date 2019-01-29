(mapcan-macro _
    '(+ - == < > <= >=)
  `((fn ,($ '%%% _) (&rest x)
      (apply (function ,_) x))))
