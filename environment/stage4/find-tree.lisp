;;;; TRE environment
;;;; Copyright (C) 2005-2009,2011 Sven Klose <pixel@copei.de>

(defun find-tree (x v &key (test #'eql))
  (or (funcall test x v)
      (and (cons? x)
           (or (find-tree x. v :test test)   
               (find-tree .x v :test test)))))
