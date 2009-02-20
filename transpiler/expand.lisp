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
		 name x.)
	(when (expander-has-macro? (transpiler-macro-expander tre) name)
	  (error "Macro ~A already defined in code-generator." name))
	(transpiler-add-unwanted-function tre name)
    `(define-expander-macro ,(transpiler-std-macro-expander tre) ,@x)))

;;;; LAMBDA EXPANSION

(defun transpiler-lambda-expand-one (tr x)
  (with (forms (when (transpiler-stack-arguments? tr)
			     (argument-expand-names
			       'transpiler-lambda-expand
			       (lambda-args x.)))
         fi	(aif (transpiler-current-funinfo tr)
				!
				(make-funinfo :env (list forms nil))))
    (prog1
	  `#'(,(lambda-args x.)
             ,@(lambda-embed-or-export
				 fi
                 (lambda-body x.)
                 (transpiler-lambda-export? tr)))
          (dolist (e (funinfo-closures fi))
            (transpiler-add-exported-closure tr e. .e)
            (transpiler-add-wanted-function tr e.)))))

(defun transpiler-lambda-expand (tr x)
  "Expand top-level LAMBDA expressions."
  (if (atom x)
	  x
	  (cons (if (lambda? x.)
				(transpiler-lambda-expand-one tr x)
				(transpiler-lambda-expand tr x.))
		    (transpiler-lambda-expand tr .x))))

(defun transpiler-expression-expand (tr x)
  (expression-expand (transpiler-expex tr) x))

; XXX introduce metacode-macros and move this to javascript/.
(define-expander 'TRANSPILER-FUNPROP)

(defun js-expanded-funref (x)
  `(%function ,x))

(defun js-expanded-fun (x)
  (with-gensym g
    `(vm-scope
	   (%var ,g)
       (%setq ,g (%function ,x))
       (%setq (%slot-value ,g tre-args) ,(simple-quote-expand x.))
       (%setq ~%ret ,g))))

;; (FUNCTION symbol | lambda-expression)
;; ;; Add symbol to list of wanted functions or obfuscate arguments of
;; ;; LAMBDA-expression.
;; ;; XXX Wouldn't this obfuscate the arguments over and over again?
(define-expander-macro TRANSPILER-FUNPROP function (x)
  (unless x
    (error "FUNCTION expects a symbol or form"))
  (if (atom x)
      (js-expanded-funref x)
      (if (eq 'no-args (second x))
	      `(%function ,(cons (first x) (cddr x)))
          (js-expanded-fun x))))

;; Must be done as a macro, or quoted %FUNCTION symbols will be lost.
(defun transpiler-restore-funs (x)
  (when x
	(if (atom x)
		(if (eq '%function x)
			'function
			x)
	   (cons (transpiler-restore-funs x.)
			 (transpiler-restore-funs .x)))))

;;;; TOPLEVEL

(defun transpiler-expand-compose (tr)
  (compose
	(fn (princ #\.)
		(force-output)
		_)

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
    (fn transpiler-expression-expand tr `(vm-scope ,_))

	#'transpiler-restore-funs
	(fn (repeat-while-changes
	     (fn expander-expand 'TRANSPILER-FUNPROP _)
		 _))
))

(defun transpiler-expand (tr x)
  (remove-if #'not
		     (mapcar (fn funcall (transpiler-expand-compose tr) _)
					 x)))

(defun transpiler-preexpand-compose (tr)
  (compose
    ; Make (SLOT-VALUE this ...) expressions for class members.
    (fn thisify (transpiler-thisify-classes tr) _)

	; Inline local functions and export constant LAMBDA expressions.
    (fn transpiler-lambda-expand tr _)

	; Make CHARACTER objects.
    #'transpiler-expand-characters

    ; Expand BACKQUOTEs, QUASIQUOTEs and compiler-macros.
    #'special-form-expand

    (fn transpiler-macroexpand tr _)

	#'quasiquote-expand

    ; Alternative standard-macros.
    ; Some macros in this pass just rename expression to bypass the
    ; standard macro-expansion.
    (fn transpiler-macroexpand tr _)

    ; Convert object-dot-member symbols to %SLOT-VALUE expressions.
    #'dot-expand

    (fn funcall (transpiler-preprocessor tr) _)))

(defun transpiler-preexpand (tr x)
  (mapcan (fn (funcall (transpiler-preexpand-compose tr) (list _)))
		  x))

(defun transpiler-preexpand-and-expand (tr forms)
  (transpiler-expand tr (transpiler-preexpand tr forms)))
