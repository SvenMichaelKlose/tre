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
  (symbol-translations nil)
  (expex nil)
  (function-args nil)
  (wanted-functions nil)
  (obfuscate? nil)
  (obfuscations nil))

(defun create-transpiler (&rest args)
  (with (tr (apply #'make-transpiler args))
    (define-expander (transpiler-std-macro-expander tr))
	(define-expander (transpiler-macro-expander tr)
					 nil nil
					 nil #'(lambda (fun x)
							 (transpiler-macrocall tr fun x)))
	(with (ex (make-expex))
	  (setf (expex-function-collector ex)
			  #'((fun args)
				  (transpiler-add-wanted-function tr fun))

			(expex-function? ex)
			  #'((fun)
				   (or (assoc fun (transpiler-function-args tr))
					   (and (not (member fun (transpiler-unwanted-functions tr)))
							(functionp (symbol-function fun)))))

			(expex-function-arguments ex)
			  #'((fun)
				   (or (cdr (assoc fun (transpiler-function-args tr)))
					   (function-arguments (symbol-function fun))))

			(transpiler-expex tr) ex))
	tr))
