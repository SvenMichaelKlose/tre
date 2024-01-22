(defmacro @ (what &body body)
  (!= (macroexpand what)
    (?
      (cons? !)
        (? (eq 'function !.)
           `(dynamic-map ,!
              ,@body)
           `(dolist ,!
              ,@body))
      (symbol? what)
        `(dynamic-map ,!
          ,@body)
      (error !))))
