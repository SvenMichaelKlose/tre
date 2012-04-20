;;;;; tré - Copyright (c) 2008-2009,2011-2012 Sven Michael Klose <pixel@copei.de>

(defun parenthized-comma-separated-list (x)
  `("(" ,@(comma-separated-list x) ")"))
