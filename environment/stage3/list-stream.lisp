;;;;; tré – Copyright (c) 2008,2012 Sven Michael Klose <pixel@copei.de>

(defun make-list-stream (x)
  (make-stream
      :fun-in #'((str)
				  (car (stream-user-detail str))
				  (= (stream-user-detail str) (cdr (stream-user-detail str))))
      :fun-out #'((c str)
                   (error "list-stream output not supported"))
      :fun-eof #'((str)
				  (not (stream-user-detail str)))
      :user-detail x))
