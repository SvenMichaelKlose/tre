;;;;; tré - Copyright (c) 2010-2011 Sven Klose <pixel@copei.de>

(defun make-cblock-taglist (x)
  (let tags nil
    (dolist (i x tags)
      (let f (car (cblock-code i))
        (when (number? f)
          (acons! f i tags)
          (setf (cblock-code i) (cdr (cblock-code i))))))))
