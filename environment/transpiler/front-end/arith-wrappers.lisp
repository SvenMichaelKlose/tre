(mapcan-macro _
    '(+ - == < > <= >=)
  `((defun ,($ '%%% _) (&rest x)
	  (apply (function ,_) x))))
