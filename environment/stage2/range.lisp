;;;;; tré – Copyright (c) 2005–2006,2008,2011–2012 Sven Michael Klose <pixel@copei.de>

(functional range-p)

(defun range-p (x bottom top)
  (& (>= x bottom)
     (<= x top)))

; XXX tests missing
