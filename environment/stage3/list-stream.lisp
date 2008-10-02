;;;; TRE environment
;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;
;;;; List stream

(defun make-list-stream (x)
  (make-stream :fun-in #'((str)
							(car (stream-user-detail str))
							(setf (stream-user-detail str) (cdr (stream-user-detail str))))
	       :fun-out #'((c str) (error "list-stream output not supported"))
	       :fun-eof #'((str)
						 (not (stream-user-detail str)))
		   :user-detail x))
