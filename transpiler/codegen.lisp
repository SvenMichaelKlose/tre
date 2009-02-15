;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

;;;; OPERATOR EXPANSION

(defmacro define-transpiler-infix (tr name)
  `(define-expander-macro ,(transpiler-macro-expander (eval tr)) ,name (x y)
	 `(%transpiler-native ,,x ,(string-downcase (string name)) " " ,,y)))

(defun transpiler-binary-expand (op args)
  (nconc (mapcan (fn `(,_ ,op))
				 (butlast args))
		 (last args)))

(defmacro define-transpiler-binary (tr op repl-op)
  (transpiler-add-plain-arg-fun (eval tr) op)
  `(progn
	 (define-expander-macro
	   ,(transpiler-macro-expander (eval tr))
	   ,op
	   (&rest args)
       `("(" ,,@(transpiler-binary-expand ,repl-op args) ")"))))

;;;; ENCAPSULATION

(defun transpiler-escape-string (x)
  (when x
	(if (in=? x. #\\ #\")
		(cons #\\
			  (cons x.
					(transpiler-escape-string .x)))
		(cons x.
			  (transpiler-escape-string .x)))))

(defun transpiler-encapsulate-strings (x)
  (if (atom x)
      (if (stringp x)
          (list '%transpiler-string (list-string (transpiler-escape-string (string-list x))))
		  x)
	  (if (eq '%transpiler-native x.)
		  x
		  (cons (transpiler-encapsulate-strings x.)
		  		(transpiler-encapsulate-strings .x)))))

;;;; EXPRESSION FINALIZATION

;; Add separators.
;;   Separators cannot be added later, because the expression bounds will
;;   disappear when everything is expanded to target-language strings in
;;   the next pass.
;; Make jump labels.
;; Remove (IDENTITY ~%RET)  expressions.
;; Add %VAR declarations for expex symbols.
(defun transpiler-finalize-sexprs (tr x)
  (when x
	(with (a          x.
		   separator  (transpiler-separator tr)
		   ret		  (transpiler-obfuscate tr '~%ret))
	  (if
		(not a)
		  ; Ignore top-level NIL.
		  (transpiler-finalize-sexprs tr .x)

	  	(atom a) 
		  ; Make jump label.
		  (cons (funcall (transpiler-make-label tr) a)
		        (transpiler-finalize-sexprs tr .x))

        (and (%setq? a)
		     (lambda? (%setq-value a)))
		  ; Recurse into function.
	      (cons `(%setq ,(%setq-place a)
				        ,(copy-recurse-into-lambda
					       (%setq-value a)
					       #'((body)
						        (transpiler-finalize-sexprs tr body))))
			    (cons separator
				      (transpiler-finalize-sexprs tr .x)))

		(eq 'function a.)
		  ; Recurse into named top-level function.
		  (cons `(function
				   ,(second a) ; name
				   (,(first (third a))
				       ,(transpiler-finalize-sexprs tr (cdr (third a)))))
				 (cons separator
				       (transpiler-finalize-sexprs tr .x)))

	    (and (identity? a)
		     (eq ret (second a)))
		  ; Ignore (IDENTITY ~%RET).
		  (transpiler-finalize-sexprs tr .x)

	    ; Just copy with separator. Make return-value assignment if missing.
		(cons (if (or (vm-jump? a)
					  (%setq? a)
					  (in? a. '%var '%transpiler-native))
				  a
				  `(%setq ,ret ,a))
			  (cons separator
				    (transpiler-finalize-sexprs tr .x)))))))

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
  (with (tre (eval tr)
		 name (first x))
    (when (expander-has-macro? (transpiler-macro-expander tre) name)
      (error "Code-generator macro ~A already defined as standard macro."
			 name))
    (transpiler-add-unwanted-function tre name)
    `(define-expander-macro ,(transpiler-macro-expander tre) ,@x)))

;;;; TOPLEVEL

(defun transpiler-generate-code-compose (tr)
  (compose (fn (princ #\o)
			   (force-output)
			   _)

		   #'transpiler-concat-string-tree

		   (fn transpiler-to-string tr _)

		   ; Expand expressions to strings.
		   (fn expander-expand (transpiler-macro-expander tr) _)

		   ; Expand top-level symbols, add expression separators.
		   (fn transpiler-finalize-sexprs tr _)

		   ; Wrap strings in %TRANSPILER-STRING expressions.
		   #'transpiler-encapsulate-strings

		   ; Obfuscate symbol-names.
		   (fn transpiler-obfuscate tr _)))

(defun transpiler-generate-code (tr x)
  (mapcar (fn funcall (transpiler-generate-code-compose tr) _)
		  x))
