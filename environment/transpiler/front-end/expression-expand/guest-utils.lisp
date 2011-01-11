;;;;; TRE compiler
;;;;; Copyright (c) 2006-2011 Sven Klose <pixel@copei.de>

(defun expex-in-env? (x)
  (and (atom x)
       (funinfo-in-env-or-lexical? *expex-funinfo* x)))

(defun expex-global-variable? (x)
  (and (atom x)
       (or (not (expex-in-env? x))
           (funinfo-in-toplevel-env? *expex-funinfo* x))
       (or (transpiler-defined-variable *current-transpiler* x)
           (global-variable? x))))

(defun expex-stack-locals? (ex)
  (and *expex-funinfo* ; Is set if we're inside a function.
	   (transpiler-stack-locals? (expex-transpiler ex))))
