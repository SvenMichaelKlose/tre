;;;; nix operating system project
;;;; lisp compiler
;;;; Copyright (C) 2005-2007 Sven Klose <pixel@copei.de>
;;;;
;;;; This is the LAMBDA expansion pass of the LISP compiler. It embeds
;;;; or exports functions from functions and allocates stack slots for
;;;; arguments and free-variable bindings, to enable the following
;;;; expression expansion.
;;;;
;;;; Expressions of the following form are inlined:
;;;;
;;;;   ((#'lambda (x) x) y)
;;;;
;;;; Functions with free variables are exported:
;;;;
;;;;   #'(lambda (x) y)

;;; Stack setup

(defun make-stackop (var fi)
  "Make stack operation. If the variable is not in the current environment,
   it is returned as is and added to the free-variable list of the funinfo."
  (aif (funinfo-env-pos fi var)
    `(%stack ,!)
    `(%vec (%stack 0) ,(or (funinfo-free-var-pos fi var)
                           (progn
                             (funinfo-add-free-var fi var)
                             (funinfo-free-var-pos fi var))))))

(defun make-stack-initialisers (args vals)
  "Make stack variable initialisers."
  `(vm-scope ,@(mapcar #'(lambda (a v)
                           `(%setq ,a ,v))
	               args vals)))

(defun make-stack-body (args vals body)
  "Make body with stack variaable initialisers."
  `(vm-scope
     ,(make-stack-initialisers args vals)
     ,@body))

(defun is-stackvar? (var fi)
  "Check if a variable is on the stack."
  (and (atom var)
    (dolist (sl (funinfo-env fi))
      (when (and sl (find var sl))
        (return t)))))

(defun vars-to-stackops! (body fi)
  "Replaces variables by stack operations. Returns modified body.
   Free variables are added to free-vars of the funinfo."
  (tree-walk body
    :ascending
      #'(lambda (e)
          (let ((x (car e)))
            (when (is-stackvar? x fi)
;	      (funinfo-add-op fi e)
              (setf (car e) (make-stackop (car e) fi))))))
  body)

;;; LAMBDA inlining

(defun lambda-embed! (lambda-call fi)
  "Replace local LAMBDA expression by its body using stack variables."
  (with-lambda-call (args vals body lambda-call)
    (verbose "(stack")
    (print-symbols args)
    (verbose ") ")
    (multiple-value-bind (a v) (argument-expand args vals)
      (vars-to-stackops! vals fi)
      (with-funinfo-env-temporary fi args
        (lambda-embed-or-export! body fi)
        (rplac-cons lambda-call (make-stack-body a v body))))))

;;; LAMBDA export

(defun replace-expr-by-funref (function-expr name fi exp-fi)
  (let ((fv (queue-list (funinfo-free-vars exp-fi))))
    (setf (car function-expr)
          (if fv
            (with-gensym g
              (funinfo-env-add-args fi (list g))
              (let ((s (make-stackop g fi)))
                `(vm-scope
                   (%setq ,s (make-array ,(length fv)))
                   ,@(mapcar #'(lambda (v)
                                 `(%set-vec ,s ,(position v fv)
                                            ,(make-stackop v fi)))
                             fv)
                   (%funref ,name ,g))))
            `(%funref ,name)))))

(defun lambda-export! (n fi)
  "Export and expand LAMBDA expression out of a function."
  (with-gensym g
    (verbose "(export ~A) " (symbol-name g))
    (eval `(%set-atom-fun ,g ,(car n)))
    (let ((f (symbol-function g)))
      (multiple-value-bind (body exp-fi)
        (atom-expand-lambda f (function-body f) (funinfo-env-this fi))
        (replace-expr-by-funref n g fi exp-fi)))))

;;; Toplevel

(defun lambda-embed-or-export! (body fi)
  "Merge LAMBDA expressions and replace variables by stack operations."
  (tree-walk body
    :ascending
      #'(lambda (x)
          (if (is-lambda-call? (car x))
              (lambda-embed! (car x) fi)
              (when (is-lambda? (car x))
                (lambda-export! x fi))))

    :dont-ascend-if
      #'(lambda (x)
          (or (is-lambda? (car x))
              (is-lambda-call? (car x)))))
  (vars-to-stackops! body fi))

(defun lambda-expand! (fun body &optional (parent-env nil))
  "Convert native function to stack function."
  (let ((args (copy-tree (function-arguments fun))))
    (multiple-value-bind (forms inits) (%stackarg-expansion! args)
      (let ((fi (make-funinfo :env (list forms parent-env))))
        (lambda-embed-or-export! body fi)
        (awhen forms
          (verbose "(args")
          (print-symbols forms)
          (verbose ") "))
        (awhen (queue-list (funinfo-free-vars fi))
          (verbose "(free")
          (print-symbols !)
          (verbose ") "))
      (values body fi)))))
