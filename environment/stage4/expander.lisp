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
  post)

(defun expander-get (name)
  (cdr (assoc name *expanders*)))

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
			(fn (cdr (assoc _. (expander-macros e))))))
    (unless call
      (setf (expander-call e)
			(fn (apply (cdr (assoc _. (expander-macros e))) ._))))
	e))

(defmacro define-expander-macro (expander-name name &rest x)
  (when (consp name)
    (error "Atom expected instead of ~A for expander ~A." name expander-name))
  `(acons! ',name
		   #'(,@x)
		   (expander-macros (expander-get ',expander-name))))

(defun expander-expand (expander-name expr)
  (let e  (expander-get expander-name)
	(funcall (expander-pre e))
    (prog1
	  (repeat-while-changes
        (fn (with-temporary *macrop-diversion* (expander-pred e)
              (with-temporary *macrocall-diversion* (expander-call e)
				(%macroexpand _))))
		expr)
      (funcall (expander-post e)))))

(defun expander-has-macro? (expander-name macro-name)
  (cdr (assoc macro-name (expander-macros (expander-get expander-name)))))
