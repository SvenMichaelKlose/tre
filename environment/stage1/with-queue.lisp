; tré – Copyright (c) 2005-2006,2008,2011–2015 Sven Michael Klose <pixel@copei.de>

(defmacro with-queue (q &body body)
  `(let* ,(@ [`(,_ (make-queue))] (ensure-list q))
     ,@body))
