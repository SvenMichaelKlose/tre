;;;;; tré – Copyright (c) 2010–2013 Sven Michael Klose <pixel@copei.de>

(defun opt-tailcall-fun-0 (fi args x name front-tag)
  (append (mapcan #'((arg val)
					   (with-gensym g ; Avoid accidential GC.
						 (funinfo-env-add fi g)
						 (funinfo-add-immutable fi g)
					     `((%setq ,arg ,val)
					       (%setq ,g ,arg))))
				  (argument-expand-names name args)
				  (cdr (%setq-value x.)))
		  `((%%vm-go ,front-tag))
		  (opt-tailcall-fun fi args .x name front-tag)))

(defun %setq-function-call? (x)
  (& (%setq? x)
     (cons? (%setq-value x))))

(defun call-of-function? (expr name)
  (& (%setq-function-call? expr)
     (eq name (car (%setq-value expr)))))

(defun sets-non-local? (fi x)
  (& (%setq? x)
     (not (funinfo-in-env? fi (%setq-place x)))))

(defun function-will-exit? (fi x)
  (?
	(not x)
	  t
	(%%vm-go? x.)
	  (when (member (cadr x.) .x :test #'eq)
		(function-will-exit? fi .x))
	(| (vm-jump? x.)
	   (%setq? x.))
	  nil
	(function-will-exit? fi .x)))

(defun opt-tailcall-fun (fi args x name front-tag)
  (when x
    (? (& (call-of-function? x. name)
  		  (function-will-exit? fi .x))
	   (opt-tailcall-fun-0 fi args x name front-tag)
	   (cons x. (opt-tailcall-fun fi args .x name front-tag)))))

(metacode-walker opt-tailcall (x)
	:if-named-function
	   (with (front-tag (make-compiler-tag)
              x x.)
         `(,front-tag
		   ,@(opt-tailcall-fun (get-lambda-funinfo x)
                               (lambda-args x)
                               (lambda-body x)
                               (lambda-name x)
                               front-tag))))
