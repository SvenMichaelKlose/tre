;;;;; tré – Copyright (c) 2010,2012 Sven Michael Klose <pixel@copei.de>

(defun metacode-expression? (x)
  (| (atom x)
     (%setq? x)
     (vm-jump? x)
     (%var? x)
     (named-lambda? x)))

(defun metacode-expression-only (x)
  (& (metacode-expression? x) x))
