;;;;; tré – Copyright (c) 2009–2010,2012–2014 Sven Michael Klose <pixel@copei.de>

(defun head? (x head &key (test #'equal))
  (alet (length head)
    (unless (< (length x) !)
      (funcall test head (subseq x 0 !)))))
