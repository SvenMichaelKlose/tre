(fn wait (continuer millisecs)
  (let timeout-id nil
    (= timeout-id (window.set-timeout [0 (window.clear-timeout timeout-id)
					                     (funcall continuer)]
                                      millisecs))))

(defmacro do-wait (millisecs &body body)
  `(funcall #'wait #'(() ,@body) ,millisecs))
