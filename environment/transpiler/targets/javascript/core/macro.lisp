; tré – Copyright (c) 2011–2015 Sven Michael Klose <pixel@copei.de>

(defvar *macros* nil)
(defvar *standard-macro-expander* nil)

,(? *have-compiler?*
    '(defmacro %defmacro (name argdef &body body)
       (unless (eq '%defmacro name)
         (with-gensym (g name-sym)
           `(progn
              (%var ,g)
              (function ,g (,(argument-expand-names name argdef) ,@body))
              ,@(js-early-symbol-maker name-sym g)
              (= *macros* (. (. ,name-sym (. ',argdef ,g)) *macros*))
              (when *standard-macro-expander*
                (set-expander-macro 'standard-macros ,name-sym ',argdef ,g :may-redefine? t))))))
    '(defmacro %defmacro (name argdef &body body)))

,(? *have-compiler?*
    '(defun macro? (name)
	   (expander-has-macro? 'standard-macros name))
    '(defun macro? (x)))

;,(? *have-compiler?*
;    (defun macroexpand (x)
;      (expander-expand 'standard-macros x)))
