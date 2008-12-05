;;;;; TRE tree processor transpiler
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Configuration

(defstruct transpiler
  std-macro-expander
  macro-expander
  separator
  unwanted-functions
  expanded-functions
  (identifier-char? nil)
  (thisify-classes nil)
  (symbol-translations nil)
  (expex nil)
  (function-args nil)
  (wanted-functions nil)
  (obfuscate? nil)
  (obfuscations nil)
  (obfuscation-exceptions nil)
  (make-label #'identity)
  (preprocessor #'identity)
  (named-functions? nil))

(defun transpiler-function-arguments? (tr fun)
  (assoc fun (transpiler-function-args tr)))

(defun transpiler-function-arguments (tr fun)
  (cdr (assoc fun (transpiler-function-args tr))))

(defun create-transpiler (&rest args)
  (with (tr (apply #'make-transpiler args))
    (define-expander (transpiler-std-macro-expander tr))
	(define-expander (transpiler-macro-expander tr)
					 :call #'(lambda (fun x)
							   (transpiler-macrocall tr fun x)))
	(with (ex (make-expex))
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

			(transpiler-expex tr) ex))
	tr))
