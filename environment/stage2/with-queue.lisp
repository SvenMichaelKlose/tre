;;;;; tré – Copyright (c) 2005-2006,2008,2011–2013 Sven Michael Klose <pixel@copei.de>

(defmacro with-queue (q &rest body)
  `(let* (,@(mapcar ^(,_ (make-queue)) (ensure-list q)))
     ,@body))
