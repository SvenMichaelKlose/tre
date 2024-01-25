(fn wait (continuer millisecs)
  (let timeout-id nil
    (= timeout-id (window.set-timeout [0 (window.clear-timeout timeout-id)
                                         (~> continuer)]
                                      millisecs))))

(defmacro do-wait (millisecs &body body)
  `(~> #'wait #'(() ,@body) ,millisecs))
