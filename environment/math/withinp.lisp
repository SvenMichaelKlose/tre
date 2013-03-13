;;;;; tré – Copyright (c) 2008–2009,2011–2012 Sven Michael Klose <pixel@copei.de>

(defun within? (x lower interval)
  (& (<= lower x)
     (< x (+ lower interval))))
