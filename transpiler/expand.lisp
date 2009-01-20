;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defun transpiler-expand-characters (x)
  (if
	(characterp x)
	  `(code-char ,(char-code x))
    (consp x)
	  (traverse #'transpiler-expand-characters x)
	x))

;; Put keywords into %QUOTE-expressions, so they can be recognized
;; as symbols during code-generation.
(defun transpiler-quote-keywords (x)
  (if
	(%quote? x)
	  x
    (and (consp x)
	     (eq 'make-hash-table (car x)))
	  x
    (keywordp x)
	  `(%quote ,x)
	(consp x)
	  (traverse #'transpiler-quote-keywords x)
	x))

;;;; STANDARD MACRO EXPANSION

(defun transpiler-macroexpand (tr x)
  (with-temporary *setf-immediate-slot-value* t
    (with-temporary *setf-functionp* (transpiler-setf-functionp tr)
      (repeat-while-changes
	    (fn expander-expand (transpiler-std-macro-expander tr) _)
		x))))

;;;; EXPANSION OF ALTERNATIVE STANDARD MACROS

(defmacro define-transpiler-std-macro (tr &rest x)
  (with (tre (eval tr)
		 name (first x))
	(when (expander-has-macro? (transpiler-macro-expander tre) name)
	  (error "Macro ~A already defined in code-generator." name))
	(transpiler-add-unwanted-function tre name)
    `(define-expander-macro ,(transpiler-std-macro-expander tre) ,@x)))

;;;; LAMBDA EXPANSION

(defun transpiler-lambda-expand (tr x)
  "Expand top-level LAMBDA expressions."
  (if (consp x)
	  (cons (if (atom x.)
			    (transpiler-lambda-expand tr x.)
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
				    (transpiler-lambda-expand tr x.)))
		    (transpiler-lambda-expand tr .x))
	  x))

(defun transpiler-expression-expand (tr x)
  (expression-expand (transpiler-expex tr) x))

;;;; TOPLEVEL

(defun transpiler-expand-compose (tr)
  (compose
    ; Add names to top-level functions for those target languages
    ; that require it.
    (fn transpiler-make-named-functions tr _)

    ; Peephole-optimization. Removes some unused code.
    #'opt-peephole

	; Quote keywords.
    #'transpiler-quote-keywords

    ; Break up nested expressions.
    ; After this pass function arguments may only be literals,
    ; constants or variables.
    (fn transpiler-expression-expand tr `(vm-scope ,_))))

(defun transpiler-expand (tr x)
  (remove-if #'not
		     (mapcar (fn funcall (transpiler-expand-compose tr) _)
					 x)))

(defun transpiler-preexpand-compose (tr)
  (compose
    ; Inline local function calls.
    ; Gives local variables stack slots.
    ;
    ; Give context to member symbols.
    (fn thisify (transpiler-thisify-classes tr) _)

    (fn transpiler-lambda-expand tr _)

	; Make CHARACTER objects.
    #'transpiler-expand-characters

    ; Expand BACKQUOTEs, QUASIQUOTEs and compiler-macros.
    #'special-form-expand

    ; Alternative standard-macros.
    ; Some macros in this pass just rename expression to bypass the
    ; standard macro-expansion.
    (fn transpiler-macroexpand tr _)

    ; Convert object-dot-member symbols to %SLOT-VALUE expressions.
    #'dot-expand

    (fn funcall (transpiler-preprocessor tr) _)))

(defun transpiler-preexpand (tr x)
  (transpiler-obfuscate-symbol tr '~%ret)
  (funcall (transpiler-preexpand-compose tr) x))

(defun transpiler-preexpand-and-expand (tr forms)
  (transpiler-expand tr (transpiler-preexpand tr forms)))
