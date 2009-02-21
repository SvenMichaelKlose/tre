;;;; TRE compiler
;;;; Copyright (C) 2006-2007 Sven Klose <pixel@copei.de>

;;; Function information.
;;;
;;; This structure contains all information required to generate a native function.
(defstruct funinfo
  ; Lists of stack variables. The rest contains the parent environments.
  (env        (cons nil nil))

  ; List of arguments.
  (args       nil)

  ; List of variables defined outside the function.
  (free-vars  nil)

  ; List of exported functions.
  (closures nil)

  (gathered-closure-infos nil)

  ; List of lexical variables exported to child functions.
  (lexicals nil)

  ; Copy of parent function's lexicals.
  (parent-lexicals nil)

  ; Function code. The format depends on the compilation pass.
  first-cblock)

(defun funinfo-add-free-var (fi var)
  "Add free variable."
  (setf (funinfo-free-vars fi) (nconc (funinfo-free-vars fi) (list var)))
  var)

(defun funinfo-env-this (fi)
  "Get current environment description."
  (car (funinfo-env fi)))

(defun funinfo-env-parent (fi)
  "Get current environment description."
  (cdr (funinfo-env fi)))

;(defun funinfo-push-env (fi forms)
;  "Open new environment."
;  (push forms (funinfo-env fi)))
 
;(defun funinfo-pop-env (fi)
;  "Close environment."
;  (pop (funinfo-env fi)))

(defun funinfo-env-add-args (fi args)
  (setf (car (funinfo-env fi)) (append (car (funinfo-env fi)) args))
  args)

(defun funinfo-arg? (fi var)
  (member var (funinfo-args fi)))

(defun funinfo-env-add (fi arg)
  (funinfo-env-add-args fi (list arg)))

(defun funinfo-free-var-pos (fi var)
  "Get index of free variable in environment vector."
  (position var (funinfo-free-vars fi)))

(defun funinfo-env-pos (fi var)
  "Get index of variable on the stack."
  (position var (funinfo-env-this fi)))

(defun funinfo-add-closure (fi name fi-closure)
  (format t "Add closure ~A~%" name)
  (acons! name fi-closure (funinfo-closures fi)))

(defun funinfo-add-gathered-closure-info (fi fi-closure)
  (nconc! (funinfo-gathered-closure-infos fi) (list fi-closure)))

(defun funinfo-add-lexical (fi name)
  (format t "Add lexical ~A~%" name)
  (push! name (funinfo-lexicals fi)))

(defun funinfo-lexical-pos (fi var)
  (position var (funinfo-lexicals fi)))

(defun funinfo-parent-lexicals-pos (fi var)
  (position var (funinfo-parent-lexicals fi)))

(defun funinfo-get-child-funinfo (fi)
  (format t "Fetching memorized FUNINFO~%")
  (pop (funinfo-gathered-closure-infos fi)))

(defmacro with-funinfo-env-temporary (fi args &rest body)
  "Execute body with new environment, containing 'args'."
  (with-gensym old-env
    `(let ,old-env (copy-tree (funinfo-env ,fi))
       (funinfo-env-add-args ,fi ,args)
       (prog1
         (progn
           ,@body)
	     (setf (funinfo-env ,fi) ,old-env)))))
