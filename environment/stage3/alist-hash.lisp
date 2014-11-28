;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@hugbox.org>

(defun alist-hash (x &key (test #'eql))
  (let h (make-hash-table :test test)
    (dolist (i x h)
      (= (href h i.) .i))))
