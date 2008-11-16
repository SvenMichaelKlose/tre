;;;; TRE environment
;;;; Copyright (C) 2005-2008 Sven Klose <pixel@copei.de>

(defmacro with-temporary (place val &rest body)
  (with-gensym old-val
    `(with (,old-val ,place)
       (setf ,place ,val)
       (prog1
         (progn
           ,@body)
         (setf ,place ,old-val)))))
