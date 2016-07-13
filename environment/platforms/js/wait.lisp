; tré – Copyright (c) 2008,2010,2012–2016 Sven Michael Klose <pixel@copei.de>

(defun wait (continuer millisecs)
  (let timeout-id nil
    (= timeout-id (window.set-timeout #'(()
				                           (window.clear-timeout timeout-id)
					                       (funcall continuer))
                                      millisecs))))

(defmacro do-wait (millisecs &body body)
  (? (enabled-pass? :cps)
     `(progn
        (wait #'(() ,@body) ,millisecs)
        ,@body)
     `(funcall #'wait #'(() ,@body) ,millisecs)))
