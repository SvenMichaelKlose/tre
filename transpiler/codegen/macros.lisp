;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

;;;; TRANSPILER-MACRO EXPANDER
;;;;
;;;; Expands code-generating macros and converts expressions to
;;;; C-style function calls.

;; Returns T for every %SETQ expression assigning the value of a function call.
(defun transpiler-macrop-funcall? (x)
  (and (consp x)
	   (%setq? x)
	   (consp (%setq-value x))
	   (not (stringp (first (%setq-value x))))
	   (not (in? (first (%setq-value x)) '%transpiler-string '%transpiler-native))))

(defun transpiler-macrocall-funcall (x)
  `("(" ,@(transpiler-binary-expand "," x) ")"))

(defun transpiler-macrocall (tr x)
  (with (expander	(expander-get (transpiler-macro-expander tr))
		 m			(assoc-value x. (expander-macros expander)))
    (if m
        (let e (apply m .x)
	       (if (transpiler-macrop-funcall? x)
				; Make C-style function call.
  		       `(,e. ,(second e) ,(first (third e))
				  ,@(transpiler-macrocall-funcall (cdr (third e))))
		       e))
		x)))

(defmacro define-transpiler-macro (tr &rest x)
  (when *show-definitions*
	(print `(define-transpiler-macro ,tr ,x.)))
  (with (tre (eval tr)
		 name x.)
    (when (expander-has-macro? (transpiler-macro-expander tre) name)
      (error "Code-generator macro ~A already defined as standard macro."
			 name))
    (transpiler-add-unwanted-function tre name)
    `(define-expander-macro ,(transpiler-macro-expander tre) ,@x)))
