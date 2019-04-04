(var *function-sources* nil)

(%defun %defun-name (name)
  (? (symbol? name)
     name
     (? (& (cons? name)
           (eq name. '=))
        (make-symbol (string-concat "=-" (string .name.)))
;                     (symbol-package (cadr name)))     ; TODO review
        (error "Illegal function name ~A. It must be a symbol or of the form (= symbol)." name))))

(defmacro defun (name args &body body)
  (let name (%defun-name name)
    `(block nil
       (print-definition `(defun ,name ,args))
       (%defun-quiet ,name ,args
         (block ,name
           (block nil
             ,@(%add-documentation name body))))
       (return-from nil ',name))))

(defmacro fn (name args &body body)
  `(defun ,name ,args ,@body))
