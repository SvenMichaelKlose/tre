; tré – Copyright (c) 2008,2011–2014 Sven Michael Klose <pixel@hugbox.org>

(defun ensure-tree (x)
  (? (cons? x.)
     x
     (list x)))
