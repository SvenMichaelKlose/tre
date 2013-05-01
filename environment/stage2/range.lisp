;;;;; tré – Copyright (c) 2005–2006,2008,2011–2013 Sven Michael Klose <pixel@copei.de>

(functional range?)

(defun range? (x bottom top)
  (& (>= x bottom)
     (<= x top)))
