;;;; nix operating system project
;;;; lisp compiler
;;;; Copyright (C) 2006-2007 Sven Klose <pixel@copei.de>

;;; Function information

(defstruct funinfo
  ; Lists of stack variables. The rest contains the parent
  ; parent environments.
  (env        (cons nil nil))
  (args       nil)
  (stack-size nil)
  (free-vars  (make-queue))
  first-cblock)

(defun funinfo-add-free-var (fi var)
  (enqueue (funinfo-free-vars fi) var)
  nil)

(defun funinfo-env-this (fi)
  (car (funinfo-env fi)))

(defun funinfo-add-op (fi op)
  (enqueue (funinfo-ops fi) op)
  nil)

(defun funinfo-push-env (fi forms)
  (push forms (funinfo-env fi))
  nil)
 
(defun funinfo-pop-env (fi)
  (pop (funinfo-env fi))
  nil)

(defun funinfo-env-add-args (fi args)
  "Add variables to the current environment."
  (setf (car (funinfo-env fi)) (if (funinfo-env-this fi)
                                   (append (funinfo-env-this fi) args)
		                   args))
  nil)

(defun funinfo-free-var-pos (fi var)
  (position var (queue-list (funinfo-free-vars fi))))

(defun funinfo-env-pos (fi var)
  (position var (funinfo-env-this fi)))

(defmacro with-funinfo-env-temporary (fi args &rest body)
  (with-gensym old-env
    `(let ((,old-env (funinfo-env ,fi)))
       (funinfo-env-add-args ,fi ,args)
       (prog1
         (progn
           ,@body)
	 (setf (funinfo-env ,fi) ,old-env)))))
