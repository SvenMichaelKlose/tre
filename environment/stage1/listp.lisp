;;;;; TRE environment
;;;;; Copyright (c) 2005,2008 Sven Klose <pixel@copei.de>

;; Return T if argument is a cons or NIL (non-atomic/end of list).
(%defun listp (x)
  (if (consp x)
	  t
      (not x)))
