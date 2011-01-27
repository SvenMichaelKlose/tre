;;;;; TRE compiler
;;;;; Copyright (c) 2010-2011 Sven Klose <pixel@copei.de>

(defun test-meta-code-0 (x)
  "Check code between expression- and place-expansions."
  (?
	(not x)
	  nil
	(atom x)
	  (progn
	    (print x)
	    (error "meta-code: illegal atom. Expression expected"))
    (progn
	  (?
	    (atom x.)
	      (unless (or (not x.)
					  (number? x.))
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
	        (when (function-expr? val)
	          (test-meta-code-0 (lambda-body val))))
	    (function-expr? x.)
	      (test-meta-code-0 (lambda-body x.))
		(progn
		  (print x)
		  (error "meta-code: SETQ-expression expected")))
	 (test-meta-code-0 .x))))

(defun test-meta-code (x)
  (test-meta-code-0 x)
  x)
