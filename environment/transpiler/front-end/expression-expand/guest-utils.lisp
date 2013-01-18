;;;;; tré – Copyright (c) 2006–2013 Sven Michael Klose <pixel@copei.de>

(defun expex-var-or-lexical? (x)
  (funinfo-var-or-lexical? *expex-funinfo* x))

(defun expex-global-variable? (x)
  (funinfo-global-variable? *expex-funinfo* x))

(defun expex-stack-locals? (ex)
  (transpiler-stack-locals? (expex-transpiler ex)))
