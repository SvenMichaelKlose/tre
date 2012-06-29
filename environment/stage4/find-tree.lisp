;;;;; tré – Copyright (c) 2005-2009,2011–2012 Sven Michael Klose <pixel@copei.de>

(defun find-tree (x v &key (test #'eql))
  (| (funcall test x v)
     (& (cons? x)
        (| (find-tree x. v :test test)   
           (find-tree .x v :test test)))))
