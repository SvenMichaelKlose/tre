;;;;; tré – Copyright (c) 2011–2013 Sven Michael Klose <pixel@copei.de>

(defvar *macros* nil)
(defvar *standard-macro-expander* nil)

,(? *have-compiler?*
    '(defmacro define-std-macro (name args &rest body)
       (unless (eq 'define-std-macro name)
         (with-gensym (g name-sym)
           `(progn
              (%var ,g)
              (function ,g (,args ,@body))
              ,@(js-early-symbol-maker name-sym g)
              (= *macros* (cons (cons ,name-sym #',g) *macros*))
              (when *standard-macro-expander*
                (set-expander-macro 'standard-macros ,name-sym #',g :may-redefine? t))))))
    '(defmacro define-std-macro (name args &rest body)))

,(? *have-compiler?*
    '(defun macrop (name)
	   (expander-has-macro? 'standard-macros name))
    '(defun macrop (x)))

(defun macroexpand (x)
  (expander-expand 'standard-macros x))
