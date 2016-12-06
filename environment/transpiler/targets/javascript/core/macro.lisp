; tré – Copyright (c) 2011–2016 Sven Michael Klose <pixel@copei.de>

(defvar *macros* nil)
(defvar *standard-macro-expander* nil)

,(? *have-compiler?*
    '(defmacro %defmacro (name argdef &body body)
       (unless (eq '%defmacro name)
         (with-gensym name-sym
           (let fun-name ($ "macrofun_" name)
             `{(%var ,fun-name)
               (%var ,name-sym)
               ,@(js-early-symbol-maker name-sym name)
               (function ,fun-name (,(argument-expand-names name argdef) ,@body))
               (= *macros* (. (. ,name-sym (. ',argdef ,fun-name)) *macros*))
               (!? *standard-macro-expander*
                   (set-expander-macro ! ,name-sym ',argdef ,fun-name :may-redefine? t))}))))
    '(defmacro %defmacro (name argdef &body body)))

,(? *have-compiler?*
    '(defun macro? (name)
	   (expander-has-macro? *standard-macro-expander* name))
    '(defun macro? (x)))
