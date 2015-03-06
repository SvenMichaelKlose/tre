; tré – Copyright (c) 2005–2009,2011–2015 Sven Michael Klose <pixel@copei.de>

(defun tree-find (v x &key (test #'eql))
  (| (funcall test v x)
     (& (cons? x)
        (@ (i x)
          (& (tree-find v i)
             (return t))))))
