;;;;; tré – Copyright (c) 2008–2009,2012 Sven Michael Klose <pixel@copei.de>

(mapcan-macro _
    '(+ - == < > <= >=)
  `((defun ,($ '%%% _) (&rest x)
	  (apply (function ,_) x))))
