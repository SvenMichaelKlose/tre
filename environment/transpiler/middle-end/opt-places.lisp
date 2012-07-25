;;;;; tré - Copyright (c) 2009-2012 Sven Michael Klose <pixel@copei.de>

(defun opt-places-find-used-fun (x)
  (let fi (get-lambda-funinfo x)
    (!? (funinfo-lexical fi)
        (funinfo-add-used-env fi !))
    (opt-places-find-used-0 fi (lambda-body x))))

(defun opt-places-find-used-0 (fi x)
  (?
    (atom x)			(& (funinfo-in-env? fi x)
						   (funinfo-add-used-env fi x))
	(%quote? x)			nil
	(lambda? x)			(opt-places-find-used-fun x)
	(named-lambda? x)	(opt-places-find-used-fun ..x.)
	(progn
	  (opt-places-find-used-0 fi x.)
      (opt-places-find-used-0 fi .x))))

(defun opt-places-find-used (x)
  (opt-places-find-used-0 (transpiler-global-funinfo *current-transpiler*) x)
  x)

(defun opt-places-correct-funinfo (fi)
  (funinfo-env-set fi (+ (funinfo-used-env fi)
                         (funinfo-lexicals fi)
                         (& (transpiler-copy-arguments-to-stack? *current-transpiler*)
                            (funinfo-args fi)))))

(defun opt-places-remove-unused-body (x)
  (let fi (get-lambda-funinfo x)
    (opt-places-correct-funinfo fi)
    (opt-places-remove-unused-0 fi (lambda-body x))))

(defun opt-places-remove-unused-0 (fi x)
  (?
    (atom x)			nil
	(lambda? x)			(opt-places-remove-unused-body x)
	(named-lambda? x)	(opt-places-remove-unused-body ..x.)
	(progn
	  (opt-places-remove-unused-0 fi x.)
      (opt-places-remove-unused-0 fi .x))))

(defun opt-places-remove-unused (x)
  (opt-places-remove-unused-0 (transpiler-global-funinfo *current-transpiler*) x)
  x)
