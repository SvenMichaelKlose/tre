;;;;; TRE compiler
;;;;; Copyright (c) 2009-2010 Sven Klose <pixel@copei.de>

(defun named-function-expr? (x)
  (and (function-expr? x)
	   ..x
	   t))

(defun opt-places-find-used-fun (fi body)
  (awhen (funinfo-lexical fi)
    (funinfo-add-used-env fi !))
  (opt-places-find-used-0 fi body))

(defun opt-places-find-used-0 (fi x)
  (if
	(%quote? x)
	  nil

    (and (atom x)
	     (funinfo-in-env? fi x))
      (funinfo-add-used-env fi x)

	(lambda? x)
	  (opt-places-find-used-fun (get-lambda-funinfo x)
							    (lambda-body x))

	(named-function-expr? x)
	  (opt-places-find-used-fun (get-lambda-funinfo (third x))
							    (lambda-body (third x)))

	(consp x)
	  (opt-places-find-used-0 fi x.))
  (when (consp x)
    (opt-places-find-used-0 fi .x)))

(defun opt-places-find-used (x)
  (opt-places-find-used-0 *global-funinfo* x)
  x)

(defun opt-places-funinfo-opt (fi)
  (funinfo-env-reset fi)
  (dolist (i (funinfo-used-env fi))
	(funinfo-env-add fi i)))

(defun opt-places-remove-unused-0 (fi x)
  (if
    (atom x)
	    nil

	(lambda? x)
	  (let fi (get-lambda-funinfo x)
	    (opt-places-funinfo-opt fi)
	    (opt-places-remove-unused-0 fi (lambda-body x)))

	(named-function-expr? x)
	  (let fi (get-lambda-funinfo (third x))
	    (opt-places-funinfo-opt fi)
	    (opt-places-remove-unused-0 fi (lambda-body (third x))))

	(opt-places-remove-unused-0 fi x.))
  (when (consp x)
    (opt-places-remove-unused-0 fi .x)))

(defun opt-places-remove-unused (x)
  (opt-places-remove-unused-0 *global-funinfo* x)
  x)
