;;;;; tré – Copyright (c) 2006–2012 Sven Michael Klose <pixel@copei.de>

(defun expex-in-env? (x)
  (& (atom x)
     (funinfo-in-env-or-lexical? *expex-funinfo* x)))

(defun expex-global-variable? (x)
  (& (atom x)
     (not (expex-in-env? x))
     (| (transpiler-defined-variable *current-transpiler* x)
        (transpiler-host-variable? *current-transpiler* x))))

(defun expex-stack-locals? (ex)
  (& *expex-funinfo* ; Is set if we're inside a function.
     (transpiler-stack-locals? (expex-transpiler ex))))
