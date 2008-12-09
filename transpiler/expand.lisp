;;;;; TRE tree processor transpiler
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

;;;; SLOT GETTER GENERATION
(defun transpiler-make-slot-values (x)
  (with (conv
		  (fn (with (sl (string-list (symbol-name _))
					 p  (position #\. sl :test #'=))
				(if (and p
						 (not (or (= p 0)
								  (= (1+ p) (length sl)))))
					`(%slot-value ,(make-symbol (list-string (subseq sl 0 p)))
								  ,(conv (make-symbol (list-string (subseq sl (1+ p))))))
					_)))
		 label?
		   (fn (not (or (consp _)
					    (numberp _)
				        (stringp _)))))
    (when x
	  ; Combine expression and next symbol to %SLOT-VALUE if the symbol and starts with
	  ; a dot.
      (cond
		((and (consp x)
			  (consp .x)
			  (label? (second x))
			  (= #\. (elt (symbol-name (second x)) 0)))
		  	(cons `(%slot-value ,(transpiler-make-slot-values x.)
							    ,(conv (make-symbol (subseq (symbol-name (second x))
														    1))))
			      (transpiler-make-slot-values (cddr x))))
		((label? x)
			(conv x))
		((consp x)
		    (cons (transpiler-make-slot-values x.)
				  (transpiler-make-slot-values .x)))
      	(t
			x)))))

;;;; STANDARD MACRO EXPANSION

(defun transpiler-macroexpand (x)
  (repeat-while-changes (fn *macroexpand-hook* _) x))

;;;; EXPANSION OF ALTERNATIVE STANDARD MACROS

(defmacro define-transpiler-std-macro (tr name args body)
  (with (tre (eval tr))
    `(define-expander-macro ',(transpiler-std-macro-expander tre)
							,name
							,args
	   ,body)))

;;;; LAMBDA EXPANSION

(defun transpiler-lambda-expand (tr x)
  "Expand top-level LAMBDA expressions."
  (if (consp x)
	  (cons (if (consp x.)
			    (if (lambda? x.)
				    (let forms (when (transpiler-stack-arguments? tr)
								 (argument-expand-names
							       'transpiler-lambda-expand
							       (lambda-args x.)))
			          `#'(,(lambda-args x.)
    			             ,@(lambda-embed-or-export
         			             (make-funinfo :env (list forms nil))
					             (lambda-body x.)
					             (transpiler-lambda-export? tr))))
				    (transpiler-lambda-expand tr x.))
			    (transpiler-lambda-expand tr x.))
		    (transpiler-lambda-expand tr .x))
	  x))

;;;; TOPLEVEL

(defun transpiler-expand-compose (tr)
  (compose
		   ; Add names to top-level functions for those target languages
		   ; that require it.
		   (fn (transpiler-make-named-functions tr _))

		   ; Peephole-optimization. Removes some unused code.
		   #'opt-peephole

		   ; Break up nested expressions.
		   ; After this pass function arguments may only be literals,
		   ; constants or variables.
	       (fn expression-expand (transpiler-expex tr) _)

		   ; Give context to member symbols.
	       (fn thisify (transpiler-thisify-classes tr) _)

		   ; Inline local function calls.
		   ; Gives local variables stack slots.
	       (fn transpiler-lambda-expand tr _)

		   ; Expand BACKQUOTEs and compiler-macros.
		   #'special-form-expand

		   ; Convert object-dot-member symbols to %SLOT-VALUE expressions.
		   #'transpiler-make-slot-values

		   ; Do standard macro-expansion
	       #'transpiler-macroexpand))

(defun transpiler-process-forms (tr fun forms)
  (with (e nil)
    (dolist (x forms e)
	  (setf e (append e (list (funcall fun x)))))))

(defun transpiler-expand (tr forms)
  (transpiler-process-forms tr (transpiler-expand-compose tr) forms))

(defun transpiler-preexpand-compose (tr)
  (compose #'list

		   #'dot-expand

		   ; Alternative standard-macros.
		   ; Some macros in this pass just rename expression to bypass the
		   ; standard macro-expansion.
	       (fn expander-expand (transpiler-std-macro-expander tr) _)

		   ; Convert dot-notation to %SLOT-VALUE expressions.
		   #'transpiler-make-slot-values

		   (fn funcall (transpiler-preprocessor tr) _)))

(defun transpiler-preexpand (tr forms)
  (transpiler-obfuscate-symbol tr '~%ret)
  (transpiler-process-forms tr (transpiler-preexpand-compose tr) forms))
