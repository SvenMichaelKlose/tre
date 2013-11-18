;;;;; tré – Copyright (c) 2010–2012 Sven Michael Klose <pixel@copei.de>

(defun element-has-name? (x)
  (& (element? x)
     (x.has-name-attribute?)))
