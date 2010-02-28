;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Wrap code around functions to save their argument definitions
;;;;; for run-time argument-expansions.

(defun simple-argument-list? (x)
  (if x
      (not (member-if (fn or (consp _)
	                         (argument-keyword? _))
				      x))
	  t))

; XXX introduce metacode-macros or lambda-expansion hooks and move this to javascript/.
(define-expander 'TRANSPILER-PREPARE-RUNTIME-ARGUMENTEXPANSIONS)

(defun js-expanded-funref (x)
  `(%function ,x))

(defun js-expanded-fun (x)
  (with-gensym g
    `(vm-scope
	   (%var ,g)
       (%setq ,g (%function ,x))
	   ,(let args (lambda-args x)
	      (when (or *transpiler-assert*
					(some (fn or (consp _)
						     	 (%arg-keyword? _))
					  	  args))
	        `(%assign-function-arguments ,g ,(simple-quote-expand args))))
       (%setq ~%ret ,g))))

;; (FUNCTION symbol | lambda-expression)
;; ;; Add symbol to list of wanted functions or obfuscate arguments of
;; ;; LAMBDA-expression.
(define-expander-macro TRANSPILER-PREPARE-RUNTIME-ARGUMENTEXPANSIONS function (&rest x)
  (when ..x
    (error "FUNCTION expects an optional name and a head/body"))
  (with (l (if .x .x. x.)
		 name (if .x x.))
    (if (or (atom l)
		    (%slot-value? l))
        (js-expanded-funref l)
        (if
		  (eq 'no-args (car (lambda-body l)))
            `(%function
			   ,@(awhen name (list !))
		       (,@(lambda-head l)
			    ,@(cdr (lambda-body l))))
	      (simple-argument-list? (lambda-args l))
		    `(%function
			   ,@(awhen name (list !))
		       (,@(lambda-head l)
			    ,@(lambda-body l)))
          (js-expanded-fun (past-lambda-before-funinfo l))))))

;; Must be done as a macro, or quoted %FUNCTION symbols will be lost.
(defun transpiler-restore-funs (x)
  (when x
	(if (atom x)
		(if (eq '%function x)
			'function
			x)
	   (cons (transpiler-restore-funs x.)
			 (transpiler-restore-funs .x)))))

(defun transpiler-prepare-runtime-argument-expansions (tr x)
  (if (transpiler-apply-argdefs? tr)
      (transpiler-restore-funs
         (expander-expand 'TRANSPILER-PREPARE-RUNTIME-ARGUMENTEXPANSIONS x))
	  x))
