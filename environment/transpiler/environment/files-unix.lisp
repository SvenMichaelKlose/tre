;;;; TRE environment
;;;; Copyright (c) 2005-2006,2008-2009 Sven Klose <pixel@copei.de>
;;;;
;;;; UN*X-related file functions

(defun %fopen-direction (direction)
  (case direction
    'input   "r"
    'output  "w"
    t	      (%error ":direction not specified")))
