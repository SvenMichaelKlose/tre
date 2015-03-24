; tré – Copyright (c) 2008–2009,2011,2013,2015 Sven Michael Klose <pixel@copei.de>

(declare-cps-exception atom identity)

(defun atom (x)
  (not (cons? x)))
