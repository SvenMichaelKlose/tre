(defmacro with-queue (q &body body)
  `(let* ,(@ [`(,_ (make-queue))] (ensure-list q))
     ,@body))
