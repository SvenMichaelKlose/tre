;;;;; TRE compiler
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defun test-meta-code-0 (x)
  "Check code between expression- and place-expansions."
  (if
	(not x)
	  nil
	(atom x)
	  (progn
	    (print x)
	    (error "meta-code: illegal atom. Expression expected"))
    (progn
	  (if
	    (atom x.)
	      (unless (or (not x.)
					  (numberp x.))
		    (print x)
		    (error "meta-code: illegal atom. Number, jump, SETQ- or function expression expected"))			   
	    (%var? x.)
	      (progn
	        (print x)
	        (error "meta-code: unexpected VAR-expression"))
		(vm-jump? x.)
		  nil
        (%setq? x.)
	      (let val (%setq-value x.)
	        (if (lambda? val)
	            (test-meta-code-0 (lambda-body val))))
		(progn
		  (print x)
		  (error "meta-code: SETQ-expression expected")))
	 (test-meta-code-0 .x))))

(defun test-meta-code (x)
  (test-meta-code-0 x)
  x)
