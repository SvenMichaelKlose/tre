;;;;; tré - Copyright (c) 2008-2009,2011 Sven Klose <pixel@copei.de>

(defun %force-output (&optional strm))

,(when *have-compiler?*
   '(defun make-standard-stream ()))
