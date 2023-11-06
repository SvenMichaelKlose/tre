(add-printer-argument-definition 'CL:LABELS      '(assignments &body body))
(add-printer-argument-definition 'CL:LAMBDA      '(args &body body))
(add-printer-argument-definition 'CL:DEFUN       '(name args &body body))
(add-printer-argument-definition 'CL:DEFMACRO    '(name args &body body))
(add-printer-argument-definition 'CL:DEFVAR      '(name init))
(add-printer-argument-definition 'CL:DEFCONSTANT '(name init))

(def-cl-transpiler-macro defun (name args &body body)
  (print-definition `(fn ,name ,args))
  (add-defined-function name args body)
  `(CL:DEFUN ,name ,args ,@body))

(def-cl-transpiler-macro defvar (name &optional (init nil))
  (print-definition `(var ,name))
  (add-defined-variable name)
  (add-delayed-expr `((CL:SETQ ,name ,init)))
  `(CL:DEFVAR ,name))

(def-cl-transpiler-macro defconstant (name &optional (init nil))
  (print-definition `(const ,name))
  (add-defined-variable name)
  (add-delayed-expr `((CL:DEFCONSTANT ,name ,init))))

(def-cl-transpiler-macro defmacro (name args &body body)
  (print-definition `(defmacro ,name ,args))
  (make-transpiler-macro name args body))

(def-cl-transpiler-macro defspecial (name args &body body)
  (print-definition `(defspecial ,name ,args))
  (add-delayed-expr `((CL:PUSH (. (tre-symbol ',name)
                                  (. ',args
                                     #'(,(argument-expand-names 'defspecial args)
                                        ,@body)))
                               *special-forms*))))

(fn make-? (body)
  (with (tests (group body 2)
         end   (car (last tests)))
    (| body
       (error "Body is missing."))
    `(CL:COND
       ,@(? .end
            tests
            (+ (butlast tests) (list (. t end)))))))

(def-cl-transpiler-macro ? (&body body)
  (make-? body))

(def-cl-transpiler-macro %%comment (&rest x)
  (concat-stringtree (convert-identifiers x)))
