;;;;; tré – Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

(defun regexp-match (reg str)
  (let m (str.match reg)
    (unless (empty-string-or-nil? m)
      m)))
