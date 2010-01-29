;;;;; TRE compiler
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defvar *global-funinfo* nil)

(defun make-global-funinfo ()
  (setf *global-funinfo* (make-funinfo)))
