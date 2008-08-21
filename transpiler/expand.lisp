;;;;; TRE tree processor transpiler
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

;;;; SLOT GETTER GENERATION

(defun transpiler-make-slot-getters (x)
  (mapatree #'((x)
				 (if (and (atom x) (not (or (numberp x) (stringp x))))
				     (with (sl (string-list (symbol-name x))
					        p (position #\. sl :test #'=))
				       (if p
					       `(%slot-value ,(make-symbol (list-string (subseq sl 0 p)))
										 ,(make-symbol (list-string (subseq sl (1+ p)))))
					       x))
					 x))
		   x))

;;;; STANDARD MACRO EXPANSION

(defun transpiler-macroexpand (x)
  (repeat-while-changes #'((x) (*macroexpand-hook* x)) x))

;;;; EXPANSION OF ALTERNATE STANDARD MACROS

(defmacro define-transpiler-std-macro (tr name args body)
  (with (tre (eval tr))
    `(define-expander-macro ,(transpiler-std-macro-expander tre)
							  ,name
							  ,args
	   ,body)))

;;;; LAMBDA EXPANSION

(defun transpiler-lambda-expand (x)
  (with ((forms inits)  (values nil nil) ; (copy-tree (function-arguments fun)))
         fi             (make-funinfo :env (list forms nil)))
    (lambda-embed-or-export x fi nil)))

;;;; TOPLEVEL

(defun transpiler-expand (tr forms)
  (with (e nil)
    (dolist (x forms e)
	  (setf e (append e
        (list (funcall
	      (compose #'opt-peephole
			       #'(lambda (x)
			           (expression-expand (transpiler-expex tr) x))
			       #'transpiler-lambda-expand
			       #'backquote-expand
			       #'compiler-macroexpand
				   #'transpiler-make-slot-getters
			       #'transpiler-macroexpand
			       #'list
			       #'(lambda (x)
				       (expander-expand (transpiler-std-macro-expander tr) x)))
	        x)))))))
