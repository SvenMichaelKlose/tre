;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
;;;;
;;;; Function definition

; Check and return keyword argument or NIL.
(%defun %defun-arg-keyword (args)
  (let ((a (car args))
        (d (and (cdr args) (cadr args))))
    (if (%arg-keyword-p a)
        (if d
            (if (%arg-keyword-p d)
                (error "keyword following keyword"))
            (error "end after keyword")))))

; Check and return argument list.
(%defun %defun-args (args)
  (if args
      (or
          (%defun-arg-keyword args)
          (cons (car args) (%defun-args (cdr args))))))

(%defun %defun-name (name)
  (if (atom name)
      name
      (if (eq (car name) '%%defunsetf)
          (make-symbol (string-concat "%%USETF-" (string (cadr name))))
          (error "illegal function name"))))

(defvar *compiler-hook* nil)

(defmacro defun (name args &rest body)
  "Define a function."
  (let ((name (%defun-name name)))
    `(tagbody
       (setq *universe* (cons ',name *universe*))
       (%set-atom-fun ,name
         #'(,(%defun-args args)
             (block ,name
               ,@(%add-documentation name body))))
       (if *compiler-hook*
           (compile (function ,name))))))
