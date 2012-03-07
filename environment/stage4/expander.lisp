;;;;; tré - Copyright (c) 2006-2009,2011-2012 Sven Michael Klose <pixel@copei.de>

(defvar *expanders* nil)
(defvar *current-expander* nil)

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

(defvar *expander-print* nil)

(defun expander-macro-function (expander-name macro-name)
  (href (expander-macros expander-name) macro-name))

(defun (setf expander-macro-function) (new-function expander-name macro-name)
  (setf (href (expander-macros expander-name) macro-name) new-function))

(defun define-expander (expander-name &key (pre nil) (post nil)
										   (pred nil) (call nil))
  (let e (make-expander :macros (make-hash-table :test #'eq)
						:pred pred
						:call call
						:pre (or pre #'(()))
						:post (or post #'(())))
    (acons! expander-name e *expanders*)
    (unless pred
      (setf (expander-pred e)
			(fn and (atom _.)
				 	(symbol-name _.)
				 	(expander-macro-function *current-expander* _.))))
    (unless call
      (setf (expander-call e)
			(fn (when *expander-print*
                  (print _))
                (apply (expander-macro-function *current-expander* _.) ._))))
    (setf (expander-lookup e)
          #'((expander name)
              (href (expander-macros expander) name)))
	e))

(defun set-expander-macro (expander-name name fun)
  (when (expander-has-macro? expander-name name)
    (warn "Macro ~A already defined." name))
  (setf (href (expander-macros (expander-get expander-name)) name) fun))

(defun set-expander-macros (expander-name lst)
  (map (fn set-expander-macro expander-name _. ._) lst))

(defmacro define-expander-macro (expander-name name args &body body)
  (unless (atom expander-name)
    (error "Atom expected as expander-name instead of ~A." expander-name))
  (unless (atom name)
    (error "Atom expected as macro-name instead of ~A for expander ~A." name expander-name))
  (with-gensym g
    `(progn
	   (when (expander-has-macro? ',expander-name ',name)
	     (warn "Macro ~A already defined." ',name))
	   (defun ,g ,args ,@body)
       (setf (href (expander-macros (expander-get ',expander-name)) ',name) #',g))))

(defun expander-expand (expander-name expr)
  (let e (expander-get expander-name)
	(funcall (expander-pre e))
    (prog1
	  (repeat-while-changes
		(fn (with-temporaries (*current-expander* e
			                   *macrop-diversion* (expander-pred e)
                               *macrocall-diversion* (expander-call e))
	          (%macroexpand _)))
		expr)
      (funcall (expander-post e)))))

(defun expander-has-macro? (expander-name macro-name)
  (href (expander-macros (expander-get expander-name)) macro-name))

(defun expander-macro-names (expander-name)
  (hashkeys (expander-macros (expander-get expander-name))))
