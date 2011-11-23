;;;;; tré - Copyright (c) 2011 Sven Klose <pixel@copei.de>

,(? *have-compiler*
    '(defun macrop (name)
	   (expander-has-macro? 'standard-macros name))
    '(defun macrop (x)))

(defvar *macros* nil)

(defmacro define-std-macro (name args &rest body)
  `(setf *macros* (cons (cons ,(list 'quote name) #'(,args ,@body)) *macros*)))

(defun macroexpand (x)
  (expander-expand 'standard-macros x))
