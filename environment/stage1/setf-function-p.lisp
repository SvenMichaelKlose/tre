;;;;; tré - Copyright (C) 2005-2009,2011 Sven Klose <pixel@copei.de>

(defun %setf-function? (x)
  (function? (eval `(function ,x))))
