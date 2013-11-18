;;;;; tré – Copyright (c) 2010–2012 Sven Michael Klose <pixel@copei.de>

(defun fileurl? (x)
  (string== "file://" (subseq x 0 7)))
