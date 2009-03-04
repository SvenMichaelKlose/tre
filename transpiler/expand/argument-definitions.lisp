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
