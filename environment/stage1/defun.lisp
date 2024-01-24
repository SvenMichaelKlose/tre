(var *function-sources* nil)

(%fn %fn-name (name)
  (? (symbol? name)
     name
     (? (& (cons? name)
           (eq name. '=))
        (make-symbol (string-concat "=-" (string .name.)))
        (error "Illegal function name ~A. It must be a symbol or of the form (= symbol)." name))))

(defmacro defun (name args &body body)
  (#'((name)
       `(block nil
          (print-definition `(fn ,name ,args))
          (%fn-quiet ,name ,args
            (block ,name
              (block nil
                ,@(%add-documentation name body))))
          (return ',name)))
      (%fn-name name)))

(defmacro fn (name args &body body)
  `(defun ,name ,args ,@body))
