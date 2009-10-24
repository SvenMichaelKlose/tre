;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(mapcan-macro _
    '(+ - = < > <= >=)
  `((defun ,($ '%%% _) (&rest x)
	  (apply (function ,_) x))))
