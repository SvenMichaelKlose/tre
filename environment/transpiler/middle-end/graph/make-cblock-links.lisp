;;;;; tré - Copyright (c) 2010-2011 Sven Klose <pixel@copei.de>

(defun tag-cblock (tags tag)
  (assoc-value tag tags :test #'=))

(defun set-unconditional-link (cb tags tag)
  (setf (cblock-next cb) (tag-cblock tags tag)))

(defun set-conditional-link (cb tags tag place next-cblock)
  (setf (cblock-conditional-next cb) (tag-cblock tags tag)
        (cblock-conditional-place cb) place
        (cblock-next cb) next-cblock))

(defun last-cblock-instruction (cb)
  (car (last (cblock-code cb))))

(defun remove-last-cblock-instruction (cb)
  (setf (cblock-code cb) (butlast (cblock-code cb))))

(defun make-cblock-links (x tags)
  (when x
    (with (cb x.
           l (last-cblock-instruction cb))
      (?
        (%%vm-go? l) (set-unconditional-link cb tags .l.)
        (%%vm-go-nil? l) (set-conditional-link cb tags ..l. .l. .x.)
        (setf (cblock-next cb) .x.))
      (when (vm-jump? l)
        (remove-last-cblock-instruction cb))
      (make-cblock-links .x tags))))
