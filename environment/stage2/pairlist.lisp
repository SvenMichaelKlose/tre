;;;;; TRE environment
;;;;; Copyright (c) 2006,2010-2011 Sven Klose <pixel@copei.de>

(functional pairlist)

(defun pairlist (keys vals)
  (mapcar #'cons keys vals))
