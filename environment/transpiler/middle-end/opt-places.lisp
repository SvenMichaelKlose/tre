;;;;; TRE compiler
;;;;; Copyright (c) 2009-2011 Sven Klose <pixel@copei.de>

(defun opt-places-find-used-fun (x)
  (let fi (get-lambda-funinfo x)
    (awhen (funinfo-lexical fi)
      (funinfo-add-used-env fi !))
    (opt-places-find-used-0 fi (lambda-body x))))

(defun opt-places-find-used-0 (fi x)
  (if
    (atom x)			(when (funinfo-in-env? fi x)
						  (funinfo-add-used-env fi x))
	(%quote? x)			nil
	(lambda? x)			(opt-places-find-used-fun x)
	(named-lambda? x)	(opt-places-find-used-fun (third x))
	(progn
	  (opt-places-find-used-0 fi x.)
      (opt-places-find-used-0 fi .x))))

(defun opt-places-find-used (x)
  (opt-places-find-used-0 (transpiler-global-funinfo *current-transpiler*) x)
  x)

(defun opt-places-correct-funinfo (fi)
  (funinfo-env-reset fi)
  (dolist (i (append (funinfo-used-env fi)
					 (funinfo-lexicals fi)))
    (funinfo-env-add fi i))
  (when (transpiler-stack-locals? *current-transpiler*)
    (funinfo-env-add-many fi (funinfo-args fi))))

(defun opt-places-remove-unused-body (x)
  (let fi (get-lambda-funinfo x)
    (opt-places-correct-funinfo fi)
    (opt-places-remove-unused-0 fi (lambda-body x))))

(defun opt-places-remove-unused-0 (fi x)
  (if
    (atom x)			nil
	(lambda? x)			(opt-places-remove-unused-body x)
	(named-lambda? x)	(opt-places-remove-unused-body (third x))
	(progn
	  (opt-places-remove-unused-0 fi x.)
      (opt-places-remove-unused-0 fi .x))))

(defun opt-places-remove-unused (x)
  (opt-places-remove-unused-0 (transpiler-global-funinfo *current-transpiler*) x)
  x)
