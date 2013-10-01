;;;;; tré – Copyright (c) 2005–2013 Sven Michael Klose <pixel@copei.de>

(defun copy-arguments-to-vars (fi)
  (& (transpiler-copy-arguments-to-stack? *transpiler*)
     (mapcan [& (funinfo-var? fi _)
                `((%setq ,(place-assign (place-expand-0 fi _)) ,_))]
             (funinfo-local-args fi))))
