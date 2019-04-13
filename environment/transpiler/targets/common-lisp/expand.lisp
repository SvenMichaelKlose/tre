(add-printer-argument-definition 'cl:labels      '(assignments &body body))
(add-printer-argument-definition 'cl:lambda      '(args &body body))
(add-printer-argument-definition 'cl:defun       '(name args &body body))
(add-printer-argument-definition 'cl:defmacro    '(name args &body body))
(add-printer-argument-definition 'cl:defvar      '(name init))
(add-printer-argument-definition 'cl:defconstant '(name init))

(def-cl-transpiler-macro defun (name args &body body)
  (print-definition `(fn ,name ,args))
  (add-defined-function name args body)
  `(cl:defun ,name ,args ,@body))

(def-cl-transpiler-macro defvar (name &optional (init nil))
  (print-definition `(var ,name))
  (add-defined-variable name)
  (add-delayed-expr `((cl:setq ,name ,init)))
  `(cl:defvar ,name))

(def-cl-transpiler-macro defconstant (name &optional (init nil))
  (print-definition `(const ,name))
  (add-defined-variable name)
  (add-delayed-expr `((cl:defconstant ,name ,init))))

(def-cl-transpiler-macro defmacro (name args &body body)
  (print-definition `(defmacro ,name ,args))
  (make-transpiler-macro name args body))

(def-cl-transpiler-macro defspecial (name args &body body)
  (print-definition `(defspecial ,name ,args))
  (add-delayed-expr `((cl:push (. (tre-symbol ',name)
                                  (. ',args
                                     #'(,(argument-expand-names 'defspecial args)
                                        ,@body)))
                               *special-forms*))))

(fn make-? (body)
  (with (tests (group body 2)
         end   (car (last tests)))
    (| body
       (error "Body is missing."))
    `(cl:cond
       ,@(? .end
            tests
            (+ (butlast tests) (list (. t end)))))))

(def-cl-transpiler-macro ? (&body body)
  (make-? body))

(def-cl-transpiler-macro %%comment (&rest x)
  (concat-stringtree (convert-identifiers x)))
