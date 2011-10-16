;;;;; tré - Copyright (c) 2010-2011 Sven Klose <pixel@copei.de>

(defun make-cblock-taglist (cblks)
  (let tags nil
    (dolist (cb cblks tags)
      (let first (car (cblock-code cb))
        (when (number? first)
          (acons! first cb tags)
          (setf (cblock-code cb) (cdr (cblock-code cb))))))))
