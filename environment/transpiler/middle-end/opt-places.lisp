;;;;; TRE compiler
;;;;; Copyright (c) 2009-2010 Sven Klose <pixel@copei.de>

(defun named-function-expr? (x)
  (and (function-expr? x)
	   ..x
	   t))

(defun opt-places-find-used-fun (x)
  (let fi (get-lambda-funinfo x)
    (awhen (funinfo-lexical fi)
      (funinfo-add-used-env fi !))
    (opt-places-find-used-0 fi (lambda-body x))))

(defun opt-places-find-used-0 (fi x)
  (if
    (atom x)						(when (funinfo-in-env? fi x)
									  (funinfo-add-used-env fi x))
	(%quote? x)						nil
	(lambda? x)						(opt-places-find-used-fun x)
	(named-function-expr? x)		(opt-places-find-used-fun (third x))
	(progn
	  (opt-places-find-used-0 fi x.)
      (opt-places-find-used-0 fi .x))))

(defun opt-places-find-used (x)
  (test-meta-code x)
  (opt-places-find-used-0 *global-funinfo* x)
  x)

(defun opt-places-funinfo-opt (fi)
  (funinfo-env-reset fi)
  (dolist (i (funinfo-used-env fi))
    (funinfo-env-add fi i)))

(defun opt-places-remove-unused-body (x)
  (let fi (get-lambda-funinfo x)
    (opt-places-funinfo-opt fi)
    (opt-places-remove-unused-0 fi (lambda-body x))))

(defun opt-places-remove-unused-0 (fi x)
  (if
    (atom x)					nil
	(lambda? x)					(opt-places-remove-unused-body x)
	(named-function-expr? x)	(opt-places-remove-unused-body (third x))
	(progn
	  (opt-places-remove-unused-0 fi x.)
      (opt-places-remove-unused-0 fi .x))))

(defun opt-places-remove-unused (x)
  (opt-places-remove-unused-0 *global-funinfo* x)
  x)
