;;;;; TRE compiler
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defun opt-tailcall-fun-0 (fi args x name front-tag)
  (format t "Tailcall resolved for function '~A'~%" (symbol-name name))
  (append (mapcan #'((arg val)
					   (with-gensym g ; Avoid accidential GC.
						 (funinfo-env-add fi g)
						 (funinfo-add-immutable fi g)
					     `((%setq ,arg ,val)
					       (%setq ,g ,arg))))
				  (argument-expand-names name args)
				  (cdr (%setq-value x.)))
		  `((vm-go ,front-tag))
		  (opt-tailcall-fun fi args .x name front-tag)))

(defun %setq-function-call? (x)
  (and (%setq? x)
	   (consp (%setq-value x))))

(defun call-of-function? (expr name)
  (and (%setq-function-call? expr)
	   (or (eq name (car (%setq-value expr)))
	       (eq (compiled-function-name name) (car (%setq-value expr))))))

(defun sets-non-local? (fi x)
  (and (%setq? x)
	   (not (funinfo-in-env? fi (%setq-place x)))))

(defun function-will-exit? (fi x)
  (if
	(not x)
	  t
	(vm-go? x.)
	  (when (member (second x.) .x :test #'eq)
		(function-will-exit? fi .x))
	(or (vm-jump? x.)
		(%setq? x.)) ;(sets-non-local? fi x.)
		;(%setq-function-call? x.))
	  nil
	(function-will-exit? fi .x)))

(defun opt-tailcall-fun (fi args x name front-tag)
  (when x
    (if (and (call-of-function? x. name)
  		     (function-will-exit? fi .x))
	    (opt-tailcall-fun-0 fi args x name front-tag)
	    (cons x. (opt-tailcall-fun fi args .x name front-tag)))))

(metacode-walker opt-tailcall (x)
	:traverse? nil
	:if-named-function
	   (let front-tag (gensym-number)
	     `(function
             ,(lambda-name x)
		     (,@(lambda-head x)
			   	  ,front-tag
		          ,@(opt-tailcall-fun (get-lambda-funinfo x)
									  (lambda-args x)
									  (lambda-body x)
								      (lambda-name x)
									  front-tag)))))
