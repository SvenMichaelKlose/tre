; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defmacro define-cl-std-macro (name args &body body)
  `(define-transpiler-std-macro *cl-transpiler* ,name ,args ,@body))

(define-cl-std-macro %set-atom-fun (x v)
  `(cl:setf (cl:symbol-function ',x) ,v))

(define-cl-std-macro %defun (name args &body body)
  (print-definition `(%defun ,name ,args))
  (add-defined-function name args body)
  `(cl:progn
     ,@(& (save-sources?)
          `((cl:push (. name
                        ',(. args (& (not (save-argdefs-only?))
                             body)))
                     *functions*)))
     (cl:defun ,name ,args ,@body)
     ,@(& (save-sources?)
          `(cl:setf (cl:gethash #',name *function-atom-sources*)
                    ',(. args (& (not (save-argdefs-only?))
                                 body))))))

(define-cl-std-macro defun (&rest x) `(%defun ,@x))

(define-cl-std-macro %defmacro (name args &body body)
  (print-definition `(%defmacro ,name ,args))
  `(cl:push (. ',name
               (. ',args
                  #'(cl:lambda ,(argument-expand-names 'define-cl-std-macro args)
                      ,@body)))
            *macros*))

(define-cl-std-macro %defvar (name &optional (init nil))
  (print-definition `(%defvar ,name))
  (add-defined-variable name)
  (add-delayed-expr `((cl:progn
                        ,@(& (save-sources?)
                             `((cl:push (. ',name ',init) *variables*)))
                        (cl:defvar ,name ,init)))))

(define-cl-std-macro defvar (&rest x) `(%defvar ,@x))
(define-cl-std-macro defconstant (&rest x) `(%defvar ,@x))

(define-cl-std-macro ? (&body body)
  (with (tests (group body 2)
         end   (car (last tests)))
    (unless body
      (error "Body is missing."))
    `(cl:cond
       ,@(? (sole? end)
            (+ (butlast tests) (list (. t end)))
            tests))))

(define-cl-std-macro cond (&body body) `(cl:cond ,@body))
(define-cl-std-macro progn (&body body) `(cl:progn ,@body))
(define-cl-std-macro block (&body body) `(cl:block ,@body))
(define-cl-std-macro return-from (&body body) `(cl:return-from ,@body))
(define-cl-std-macro tagbody (&body body) `(cl:tagbody ,@body))
(define-cl-std-macro go (&body body) `(cl:go ,@body))
(define-cl-std-macro labels (&body body) `(cl:labels ,@body))
