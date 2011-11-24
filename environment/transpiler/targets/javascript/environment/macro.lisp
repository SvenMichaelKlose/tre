;;;;; tré - Copyright (c) 2011 Sven Klose <pixel@copei.de>

(defvar *macros* nil)

,(? *have-compiler*
    '(defmacro define-std-macro (name args &rest body)
       (unless (eq 'define-std-macro name)
         (with-gensym (g name-sym)
           `(progn
              (%defsetq ,g #'(,args ,@body))
              ,@(js-make-early-symbol-expr name-sym name)
              (%setq *macros* (cons (cons ,name-sym ,g) *macros*))))))
    '(defmacro define-std-macro (name args &rest body)))

,(? *have-compiler*
    '(defun macrop (name)
	   (expander-has-macro? 'standard-macros name))
    '(defun macrop (x)))

(defun macroexpand (x)
  (expander-expand 'standard-macros x))
