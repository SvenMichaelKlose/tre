;;;;; tré – Copyright (c) 2005–2009,2011–2013 Sven Michael Klose <pixel@copei.de>

(defun find-tree (v x &key (test #'eql))
  (| (funcall test v x)
     (& (cons? x)
        (| (find-tree v x. :test test)   
           (find-tree v .x :test test)))))
