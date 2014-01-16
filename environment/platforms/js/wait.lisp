;;;;; tré – Copyright (c) 2008,2010,2012–2014 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate clear-timeout set-timeout)
(declare-cps-exception wait)
(declare-cps-wrapper wait)
(declare-native-cps-function wait)

(defun wait (millisecs)
  (let timeout-id nil
    (= timeout-id (window.set-timeout #'(()
				                           (window.clear-timeout timeout-id)
					                       (funcall ~%cont))
                                      millisecs))))

(defmacro do-wait (millisecs &body body)
  (? (transpiler-cps-transformation? *transpiler*)
     `(progn
        (wait ,millisecs)
        ,@body)
     `(funcall #'wait #'(() ,@body) ,millisecs)))
