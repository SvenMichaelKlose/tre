;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defun length (x)
  (?
    (not x) 0
    (cons? x) (list-length x)
    (string? x) (strlen x)
    (sizeof x)))

(defun split (obj seq &key (test #'eql))
  (? (& (eq #'eql test) (string? seq))
     (array-list (explode (? (character? obj)
                             (char-string obj)
                             obj)
                          seq))
     (generic-split obj seq)))
