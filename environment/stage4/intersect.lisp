;;;;; tré – Copyright (c) 2009,2012,2014 Sven Michael Klose <pixel@hugbox.org>

(defun intersect (a b &key (test #'eql))
  (& a b
     (? (member a. b :test test)
        (. a. (intersect .a b))
        (intersect .a b))))
