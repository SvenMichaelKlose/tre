; tré – Copyright (c) 2008,2010–2013,2016 Sven Michael Klose <pixel@copei.de>

(functional assoc-value)

(defun assoc-value (key lst &key (test #'eql))
  (cdr (assoc key lst :test test)))

(defun (= assoc-value) (val key lst &key (test #'eql))
  (!? (assoc key lst :test test)
      (= .! val)
      (acons! key val lst)))
