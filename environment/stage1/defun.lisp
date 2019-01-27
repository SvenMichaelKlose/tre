(var *function-sources* nil)

(%defun %defun-arg-keyword (args)
  (let a args.
	(let d (& .args .args.)
      (? (%arg-keyword? a)
         (? d
            (? (%arg-keyword? d)
               (error "Keyword ~A follows keyword ~A." d a))
            (error "Unexpected end of argument list after keyword ~A." a))))))

(%defun %defun-checked-args (args)
  (& args
     (| (%defun-arg-keyword args)
        (. args. (%defun-checked-args .args)))))

(%defun %defun-name (name)
  (? (symbol? name)
     name
     (? (& (cons? name)
           (eq name. '=))
        (make-symbol (string-concat "=-" (string .name.)))
;                     (symbol-package (cadr name)))
        (error "Illegal function name ~A. It must be a symbol or of the form (= symbol)." name))))

(defmacro defun (name args &body body)
  (let name (%defun-name name)
    `(block nil
	   (print-definition `(defun ,name ,args))
       (%defun-quiet ,name ,(%defun-checked-args args)
         (block ,name
           (block nil
             ,@(%add-documentation name body))))
	   (return-from nil ',name))))

(defmacro fn (name args &body body)
  `(defun ,name ,args ,@body))
