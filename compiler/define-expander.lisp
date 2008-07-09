;;;;; nix operating system project
;;;;; lisp compiler
;;;;; Copyright (c) 2006-2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; User-defineable expansion.

(defvar *expanders* nil)

(defstruct expander
  macros
  pred
  call
  pre
  post)

(defun define-expander (expander-name &optional (pre nil) (post nil) (pred nil) (call nil))
  (with (e  (make-expander :macros nil
						   :pred pred
						   :call call
						   :pre #'(lambda ())
						   :post #'(lambda  ())))
    (acons! expander-name e *expanders*)
    (unless pred
      (setf (expander-pred e) #'(lambda (x)
							      (assoc x (expander-macros e)))))
    (unless call
      (setf (expander-call e) #'(lambda (fun x)
                                  (apply (assoc fun (expander-macros e)) x))))))

(defmacro define-expander-macro (expander-name name args body)
   (unless (atom name)
     (error "Atom expected instead of ~A for expander ~A." name expander-name))
  `(acons! ',name
			#'(,args
			    ,@(macroexpand body))
		   (expander-macros (assoc ,expander-name *expanders*))))

(defun repeat-while-changes (fun x)
 (with (new (funcall fun x))
   (if (equal x new)
	   x
	   (repeat-while-changes fun new))))

(defun expander-expand (expander-name expr)
  (with (e       (assoc expander-name *expanders*))
    (setq *macrop-diversion* (expander-pred e)
	      *macrocall-diversion* (expander-call e))
	(funcall (expander-pre e))
    (prog1
	  (repeat-while-changes #'%macroexpand expr)
      (setq *macrop-diversion* nil
	        *macrocall-diversion* nil)
	  (funcall (expander-post e)))))

(defun expander-has-macro? (expander-name macro-name)
  (assoc macro-name (expander-macros (assoc expander-name *expanders*))))
