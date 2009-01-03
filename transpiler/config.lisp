;;;;; TRE tree processor transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Configuration

(defstruct transpiler
  std-macro-expander
  macro-expander
  setf-functionp
  separator
  unwanted-functions
  (identifier-char?
	(fn error "structure 'transpiler': IDENTIFIER-CHAR? is not initialised"))
  (expex nil)
  (wanted-functions nil)
  (obfuscate? nil)
  (obfuscation-exceptions nil)
  (make-label #'identity)
  (preprocessor #'identity)
  (named-functions? nil)
  (lambda-export? nil)
  (stack-arguments? nil)

  ; You shouldn't have to tweak these at construction-time:
  (symbol-translations nil)
  thisify-classes
  function-args
  emitted-wanted-functions
  obfuscations)

(defun transpiler-reset (tr)
  (setf (transpiler-thisify-classes tr) (make-hash-table)	; thisified classes.
  		(transpiler-function-args tr) nil
  		(transpiler-emitted-wanted-functions tr) nil
  		(transpiler-obfuscations tr) (make-hash-table)))

(defun transpiler-switch-obfuscator (tr on?)
  (setf  (transpiler-obfuscations tr) (make-hash-table)
		 (transpiler-obfuscate? tr) on?))

(defun transpiler-function-arguments? (tr fun)
  (assoc fun (transpiler-function-args tr)))

(defun transpiler-function-arguments (tr fun)
  (cdr (assoc fun (transpiler-function-args tr))))

(defun create-transpiler (&rest args)
  (with (tr (apply #'make-transpiler args)
		 ex (make-expex))
	(transpiler-reset tr)
    (define-expander (transpiler-std-macro-expander tr))
	(define-expander (transpiler-macro-expander tr)
					 :call (fn transpiler-macrocall tr _))
    (setf (expex-function-collector ex)
		  #'((fun args)
			   (transpiler-add-wanted-function tr fun))

		  (expex-function? ex)
		  #'((fun)
			   (or (assoc fun (transpiler-function-args tr))
				   (and (or (eq t (transpiler-unwanted-functions tr))
						    (not (member fun (transpiler-unwanted-functions tr))))
						(functionp (symbol-function fun)))))

		  (expex-function-arguments ex)
		  #'((fun)
			   (or (transpiler-function-arguments tr fun)
				   (function-arguments (symbol-function fun))))

		  (transpiler-expex tr) ex)
	tr))
