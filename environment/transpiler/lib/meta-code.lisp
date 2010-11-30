;;;;; TRE transpiler
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defun metacode-expression? (x)
  (or (atom x)
      (%setq? x)
      (vm-jump? x)
      (%var? x)
      (named-lambda? x)))

(defun metacode-expression-only (x)
  (when (metacode-expression? x)
    x))
