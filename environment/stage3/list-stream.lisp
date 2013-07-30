;;;;; tré – Copyright (c) 2008,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun make-list-stream (x)
  (make-stream
      :fun-in #'((str)
				  (car (stream-user-detail str))
				  (= (stream-user-detail str) (cdr (stream-user-detail str))))
      :fun-out #'((c str)
                   (error "LIST-STREAM cannot output."))
      :fun-eof #'((str)
				  (not (stream-user-detail str)))
      :user-detail x))
