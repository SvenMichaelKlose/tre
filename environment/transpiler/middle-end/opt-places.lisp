;;;;; TRE compiler
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun opt-places-find-used-0 (x)
  (if
    (atom x)
	    nil

	(and (%stack? x)
		 ..x)
		(funinfo-add-used-env (get-lambda-funinfo-by-sym .x.)
							  ..x.)

	(and (%vec? x)
		 ...x) 
	    (if (consp .x.)
			(opt-places-find-used-0 .x.)
		    (funinfo-add-used-env (get-lambda-funinfo-by-sym ..x.)
							   	  ...x.))

	(lambda? x)
	    (opt-places-find-used-0 (lambda-body x))

    (%slot-value? x)
        (opt-places-find-used-0 .x.)

    (cons (opt-places-find-used-0 x.)
		  (opt-places-find-used-0 .x))))

(defun opt-places-find-used (x)
  (opt-places-find-used-0 x)
  x)

(defun opt-places-funinfo-opt (fi)
  (let locals (funinfo-env fi)
	(dolist (i (funinfo-env fi))
	  (unless (member i (funinfo-used-env fi) :test #'eq)
		(remove! i locals)))
	(setf (funinfo-env fi) locals)))

(defun named-function-expr? (x)
  (and (function-expr? x)
	   ..x
	   t))

(defun opt-places-remove-unused-0 (x)
  (if
    (atom x)
	    nil

	(named-function-expr? x)
		(progn
		  (opt-places-funinfo-opt (get-lambda-funinfo-by-sym (second (third x))))
		  (opt-places-remove-unused-0 (cdddr (third x))))

    (cons (opt-places-remove-unused-0 x.)
		  (opt-places-remove-unused-0 .x))))

(defun opt-places-remove-unused (x)
  (opt-places-remove-unused-0 x)
  x)
