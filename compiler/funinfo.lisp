;;;; nix operating system project
;;;; lisp compiler
;;;; Copyright (C) 2006-2007 Sven Klose <pixel@copei.de>

(defstruct argument-place
  ; Object pointer?
  (is-object nil)

  ; Stack position.
  (stack-position nil)

  ; Rest list argument to which to append this argument.
  (restlist nil))

;;; Function information.
;;;
;;; This structure contains all information required to generate a native function.
(defstruct funinfo
  ; Lists of stack variables. The rest contains the parent environments.
  (env        (cons nil nil))

  ; List of arguments.
  (args       nil)

  ; Argument expansion description.
  ;
  ; Tells, where arguments must be placed on the stack or if they must be
  ; placed on a rest list. This is used to insert argument passing instructions.
  (argument-places nil)

  ; Called functions.
  (callees nil)

  ; Total size of stack with arguments and local variables.
  (stack-size nil)

  ; List of variables defined outside the function.
  (free-vars  (make-queue))

  ; Function code. The format depends on the compilation pass.
  first-cblock)

(defun funinfo-add-free-var (fi var)
  "Add free variable."
  (enqueue (funinfo-free-vars fi) var)
  nil)

(defun funinfo-env-this (fi)
  "Get current environment description."
  (car (funinfo-env fi)))

(defun funinfo-push-env (fi forms)
  "Open new environment."
  (push forms (funinfo-env fi))
  nil)
 
(defun funinfo-pop-env (fi)
  "Close environment."
  (pop (funinfo-env fi))
  nil)

(defun funinfo-env-add-args (fi args)
  "Add variables to the current environment."
  (setf (car (funinfo-env fi)) (append (car (funinfo-env fi)) args))
  nil)

(defun funinfo-free-var-pos (fi var)
  "Get index of free variable in environment vector."
  (position var (queue-list (funinfo-free-vars fi))))

(defun funinfo-env-pos (fi var)
  "Get index of variable on the stack."
  (position var (funinfo-env-this fi)))

(defmacro with-funinfo-env-temporary (fi args &rest body)
  "Execute body with new environment, containing 'args'."
  (with-gensym old-env
    `(let ,old-env (copy-tree (funinfo-env ,fi))
       (funinfo-env-add-args ,fi ,args)
       (prog1
         (progn
           ,@body)
	     (setf (funinfo-env ,fi) ,old-env)))))
