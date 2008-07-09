;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2006, 2008 Sven Klose <pixel@copei.de>
;;;;
;;;; String stream

(defun make-string-stream ()
  "Makes stream which accumulates all strings written to it.
   See also GET-STREAM-STRING."
  (make-stream
    :user-detail  (make-queue)
    :fun-in       #'((str)
                       (queue-pop (stream-user-detail str)))
    :fun-out      #'((c str)
                       (enqueue (stream-user-detail str) c))
	:fun-eof	  #'((str)
					   (eq (stream-user-detail str) nil))))

(defun get-stream-string (str)
  "Returns string accumulated by string-stream. The stream is
   emptied. See also MAKE-STRING-STREAM."
  (prog1
	(queue-string (stream-user-detail str))
	(setf (stream-user-detail str) (make-queue))))
