(fn make-string-stream ()
  (make-stream
      :user-detail (make-queue)
      :fun-in #'((str)
                  (queue-pop (stream-user-detail str)))
      :fun-out #'((x str)
                   (? (string? x)
                      (dosequence (i x)
				        (enqueue (stream-user-detail str) i))
				      (enqueue (stream-user-detail str) x)))
	  :fun-eof #'((str)
			       (not (queue-list (stream-user-detail str))))))

(fn get-stream-string (str)
  (prog1
	(queue-string (stream-user-detail str))
	(= (stream-user-detail str) (make-queue))))
