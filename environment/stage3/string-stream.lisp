;;;; TRE environment
;;;; Copyright (C) 2005-2006,2008,2010 Sven Klose <pixel@copei.de>

(defun make-string-stream ()
  (make-stream
      :user-detail  (make-queue)
      :fun-in       #'((str)
                         (queue-pop (stream-user-detail str)))
      :fun-out      #'((x str)
					     (if (stringp x)
						     (enqueue-list (stream-user-detail str)
										   (string-list x))
                       	     (enqueue (stream-user-detail str) x)))
	  :fun-eof	  #'((str)
					     (not (queue-list (stream-user-detail str))))))

(defun get-stream-string (str)
  (prog1
	(queue-string (stream-user-detail str))
	(setf (stream-user-detail str) (make-queue))))
