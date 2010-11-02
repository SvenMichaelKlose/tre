;;;;; TRE environment
;;;;; Copyright (c) 2006,2010 Sven Klose <pixel@copei.de>

(defun pairlist (keys vals)
  (if keys   
      (acons (car keys) (car vals)
             (pairlist (cdr keys) (cdr vals)))
      (if vals
        (%error "lists must have the same length"))))
