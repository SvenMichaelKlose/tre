;;;;; tré - Copyright (c) 2005-2006,2008,2012 Sven Michael Klose <pixel@copei.de>

(defmacro return (&optional (expr nil))
  `(return-from nil ,expr))
