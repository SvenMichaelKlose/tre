;;;;; TRE environment
;;;;; Copyright (C) 2006 Sven Klose <pixel@copei.de>

(defun pairlis (keys vals)
  "Merge lists into associative list."
  (if keys   
      (acons (car keys) (car vals)
             (pairlis (cdr keys) (cdr vals)))
      (if vals
        (%error "lists must have the same length"))))
