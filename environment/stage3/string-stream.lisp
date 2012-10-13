;;;;; tré – Copyright (c) 2005–2006,2008,2010–2012 Sven Michael Klose <pixel@copei.de>

(defun make-string-stream ()
  (make-stream
      :user-detail (make-queue)
      :fun-in #'((str)
                  (let buf (queue-list (stream-user-detail str))
                    (when (string? buf.)
                      (= (stream-user-detail str) (make-queue))
                      (enqueue-list (stream-user-detail str) (append (string-list buf.) .buf))))
                  (queue-pop (stream-user-detail str)))
      :fun-out #'((x str)
				   (enqueue (stream-user-detail str) x))
	  :fun-eof #'((str)
			       (not (queue-list (stream-user-detail str))))))

(defun get-stream-string (str)
  (prog1
	(queue-string (stream-user-detail str))
	(= (stream-user-detail str) (make-queue))))
