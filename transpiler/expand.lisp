;;;;; TRE tree processor transpiler
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

;;;; SLOT GETTER GENERATION

(defun transpiler-make-slot-getters (x)
  (mapatree #'((x)
				 (if (and (atom x)
						  (not (or (numberp x)
								   (stringp x))))
				     (with (sl (string-list (symbol-name x))
					        p (position #\. sl :test #'=))
				       (if (and p
								(not (or (= p 0)
										 (= (1+ p) (length sl)))))
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
	      (compose ; Peephole-optimization.
				   ; Removes some unused code.
				   #'opt-peephole

				   ; Break up nested expressions.
				   ; After this pass function arguments may only be literals,
				   ; constants or variables.
			       #'(lambda (x)
			           (expression-expand (transpiler-expex tr) x))

				   ; Inline local function calls.
				   ; Gives local variables stack slots.
			       #'transpiler-lambda-expand

				   ; Convert backquote-expressions into consing run-time expressions.
			       #'backquote-expand

				   ; Converts built-in control-forms into simpler meta-code.
				   ; The resulting code uses only (un)conditional jumps to
				   ; labels.
			       #'compiler-macroexpand

				   ; Do standard macro-expansion
			       #'transpiler-macroexpand

				   ; XXX Prepare for macro expansion.
			       #'list

				   ; Alternative standard-macros.
				   ; Some macros in this pass just rename expression to bypass the
				   ; standard macro-expansion.
			       #'(lambda (x)
				       (expander-expand (transpiler-std-macro-expander tr) x))

				   ; Convert dot-notation to %SLOT-VALUE expressions.
				   #'transpiler-make-slot-getters)
	        x)))))))
