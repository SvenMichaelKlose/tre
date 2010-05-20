;;;;; TRE environment
;;;;; Copyright (c) 2006-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; User-defineable expansion.

(defvar *expanders* nil)

(defstruct expander
  macros
  pred
  call
  pre
  post
  lookup
  user) ; For external use.

(defun expander-get (name)
  (cdr (assoc name *expanders* :test #'eq)))

(defun define-expander (expander-name &key (pre nil) (post nil)
										   (pred nil) (call nil))
  (let e  (make-expander :macros nil
						 :pred pred
						 :call call
						 :pre #'(())
						 :post #'(()))
    (acons! expander-name e *expanders*)
    (unless pred
      (setf (expander-pred e)
			(lx (e)
				(fn (and (atom _.)
					 	 (symbol-name _.)
					 	 (cdr (assoc _. (expander-macros ,e) :test #'eq)))))))
    (unless call
      (setf (expander-call e)
			(lx (e)
				(fn (apply (cdr (assoc _. (expander-macros ,e) :test #'eq)) ._)))))
    (setf (expander-lookup e)
          #'((expander name)
			  (cdr (assoc name (expander-macros expander) :test #'eq))))
	e))

(defun set-expander-macro (expander-name name args-and-body)
  (when (expander-has-macro? expander-name name)
    (error "Macro ~A already defined." name))
  (acons! name
	      args-and-body
		  (expander-macros (expander-get expander-name))))

(defmacro define-expander-macro (expander-name name &rest x)
  (unless (atom expander-name)
    (error "Atom expected as expander-name instead of ~A." expander-name))
  (unless (atom name)
    (error "Atom expected as macro-name instead of ~A for expander ~A." name expander-name))
  (with-gensym g
    `(progn
	   (when (expander-has-macro? ',expander-name ',name)
	     (error "Macro ~A already defined." ',name))
	   ;(defun ,g ,@x)
	   (acons! ',name #',x (expander-macros (expander-get ',expander-name))))))

(defun expander-expand (expander-name expr)
  (let e (expander-get expander-name)
	(funcall (expander-pre e))
    (prog1
	  (repeat-while-changes
        (lx (e)
			(fn (with-temporary *macrop-diversion* (expander-pred ,e)
                  (with-temporary *macrocall-diversion* (expander-call ,e)
				    (%macroexpand _)))))
		expr)
      (funcall (expander-post e)))))

(defun expander-has-macro? (expander-name macro-name)
  (cdr (assoc macro-name (expander-macros (expander-get expander-name))
			  :test #'eq)))

(defun expander-macro-names (expander-name)
  (carlist (expander-macros (expander-get expander-name))))
