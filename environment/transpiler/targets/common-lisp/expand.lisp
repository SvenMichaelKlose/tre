; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defun make-%defun-quiet (name args body)
  `(cl:progn
     (cl:push (. ',name ',(. args body)) *functions*)
     (cl:defun ,name ,args ,@body)
     (cl:setf (cl:gethash #',name *function-atom-sources*) ',(. args body))))

(defmacro define-cl-std-macro (name args &body body)
  `(define-transpiler-std-macro *cl-transpiler* ,name ,args ,@body))

(define-cl-std-macro %set-atom-fun (x v)
  `(cl:setf (cl:symbol-function ',x) ,v))

(define-cl-std-macro defun (name args &body body)
  (print-definition `(defun ,name))
  (add-defined-function name args body)
  `(cl:defun ,name ,args ,@body))

(define-cl-std-macro defvar (name &optional (init nil))
  (print-definition `(defvar ,name))
  (add-defined-variable name)
  (add-delayed-expr `((cl:defvar ,name ,init))))

(define-cl-std-macro defconstant (name &optional (init nil))
  (print-definition `(defconstant ,name))
  (add-defined-variable name)
  (add-delayed-expr `((cl:defconstant ,name ,init))))

(define-cl-std-macro defmacro (name args &body body)
  (print-definition `(defmacro ,name ,args))
  (make-transpiler-std-macro name args body))

(define-cl-std-macro defspecial (name args &body body)
  (print-definition `(defspecial ,name ,args))
  (add-delayed-expr `((cl:push (. (make-symbol ,(symbol-name name) "TRE")
                                  (. (list ,@(filter [? (& (symbol? _)
                                                           (not (t? _)))
                                                        `(make-symbol ,(symbol-name _) "TRE")
                                                        `',_]
                                                     args))
                                     #'(cl:lambda ,(argument-expand-names 'defspecial args)
                                         ,@body)))
                               *macros*))))

(defun make-? (body)
  (with (tests (group body 2)
         end   (car (last tests)))
    (unless body
      (error "Body is missing."))
    `(cl:cond
       ,@(? (sole? end)
            (+ (butlast tests) (list (. t end)))
            tests))))

(define-cl-std-macro ? (&body body)
  (make-? body))

(define-cl-std-macro setq (&body body) `(cl:setq ,@body))
(define-cl-std-macro cond (&body body) `(cl:cond ,@body))
(define-cl-std-macro progn (&body body) `(cl:progn ,@body))
(define-cl-std-macro block (&body body) `(cl:block ,@body))
(define-cl-std-macro return-from (&body body) `(cl:return-from ,@body))
(define-cl-std-macro tagbody (&body body) `(cl:tagbody ,@body))
(define-cl-std-macro go (&body body) `(cl:go ,@body))
(define-cl-std-macro labels (&body body) `(cl:labels ,@body))
