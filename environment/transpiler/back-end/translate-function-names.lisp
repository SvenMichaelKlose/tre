;;;;; TRE transpiler
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Convert function names.

(defvar *codegen-num-instructions* 0)

(defun translate-function-names-0 (x)
  (if
    (named-function-expr? x)
	  (copy-lambda x :name (compiled-function-name .x.)
				     :body (translate-function-names (lambda-body x)))
    (%setq-lambda? x)
	  `(%setq ,(%setq-place x)
			  ,(copy-lambda (%setq-value x)
							:body (translate-function-names (lambda-body (%setq-value x)))))
	(and (%setq-funcall? x)
		 (transpiler-defined-function *current-transpiler* (first (%setq-value x))))
	  `(%setq ,(%setq-place x)
			  (,(compiled-function-name (first (%setq-value x)))
			   ,@(rest (%setq-value x))))
	(%setq? x)
	  (with (plc (if (transpiler-defined-function *current-transpiler* (%setq-place x))
				     (compiled-function-name (%setq-place x))
					 (%setq-place x))
	  		 val (if (transpiler-defined-function *current-transpiler* (%setq-value x))
				     (compiled-function-name (%setq-value x))
					 (%setq-value x)))
	    `(%setq ,plc ,val))
	(%var? x)
	  `(%var ,(if (transpiler-defined-function *current-transpiler* (second x))
				  (compiled-function-name (second x))
				  (second x)))
	x))

(defun translate-function-names (x)
  (mapcar #'translate-function-names-0 x))
