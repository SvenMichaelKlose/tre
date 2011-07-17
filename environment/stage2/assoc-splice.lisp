;;;; TRE environment
;;;; Copyright (C) 2005-2008,2011 Sven Klose <pixel@copei.de>

(functional assoc-splice)

(defun assoc-splice (x)
  (values (carlist x) (cdrlist x)))
