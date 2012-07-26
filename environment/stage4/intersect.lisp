;;;;; tré – Copyright (c) 2009,2012 Sven Michael Klose <pixel@copei.de>

(defun intersect (a b &key (test #'eql))
  (& a b
     (? (member a. b :test test)
        (cons a. (intersect .a b))
        (intersect .a b))))
