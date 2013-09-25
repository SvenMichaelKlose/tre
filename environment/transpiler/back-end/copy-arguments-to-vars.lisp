;;;;; tré – Copyright (c) 2005–2013 Sven Michael Klose <pixel@copei.de>

(defun copy-arguments-to-vars (fi)
  (& (transpiler-stack-locals? *transpiler*)
     (mapcar ^(%setq ,(place-assign (place-expand-0 fi _)) ,_)
             (funinfo-local-args fi))))
