;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

; XXX introduce metacode-macros and move this to javascript/.
(define-expander 'TRANSPILER-FUNPROP)

(defun js-expanded-funref (x)
  `(%function ,x))

(defun js-expanded-fun (x)
  (with-gensym g
    `(vm-scope
	   (%var ,g)
       (%setq ,g (%function ,x))
       (%setq (%slot-value ,g tre-args)
			      ,(simple-quote-expand (lambda-args x)))
       (%setq ~%ret ,g))))

;; (FUNCTION symbol | lambda-expression)
;; ;; Add symbol to list of wanted functions or obfuscate arguments of
;; ;; LAMBDA-expression.
;; ;; XXX Wouldn't this obfuscate the arguments over and over again?
(define-expander-macro TRANSPILER-FUNPROP function (l)
  (unless l
    (error "FUNCTION expects a symbol or form"))
  (if (or (atom l)
		  (%slot-value? l))
      (js-expanded-funref l)
      (if (eq 'no-args (first (lambda-body l)))
          `(%function
		     (,@(lambda-funinfo-expr l)
			  ,(lambda-args l)
			  ,@(cdr (lambda-body l))))
          (js-expanded-fun (past-lambda-before-funinfo l)))))

;; Must be done as a macro, or quoted %FUNCTION symbols will be lost.
(defun transpiler-restore-funs (x)
  (when x
	(if (atom x)
		(if (eq '%function x)
			'function
			x)
	   (cons (transpiler-restore-funs x.)
			 (transpiler-restore-funs .x)))))

(defun transpiler-argument-definitions (tr x)
  (if (transpiler-apply-argdefs? tr)
      (transpiler-restore-funs
        (repeat-while-changes
            (fn expander-expand 'TRANSPILER-FUNPROP _)
            x))
	  x))
