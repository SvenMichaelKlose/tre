; tré – Copyright (c) 2015 Sven Michael Klose <pixel@hugbox.org>

(defmacro @ (what &body body)
  (alet (macroexpand what)
    (?
      (cons? !)
        (? (eq 'function (car !))
           `(mapcar ,! ,@body)
           `(dolist ,! ,@body))
      (symbol? what)
        `(mapcar ,! ,@body)
      (error !))))
