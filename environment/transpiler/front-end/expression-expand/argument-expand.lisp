;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun %expex-argument-expand-rest (args)
  (& args
     `(cons ,args. ,(%expex-argument-expand-rest .args))))

(defun argument-values-without-cps (fun vals)
  (? (& (not (in-cps-mode?))
        (transpiler-cps-function? *transpiler* fun))
     .vals
     vals))

(defun expex-argument-expand (fun def vals)
  (filter [? (& (cons? _)
                (argument-rest-keyword? _.))
             (%expex-argument-expand-rest ._)
             _]
          (cdrlist (argument-expand fun def (argument-values-without-cps fun vals) t))))
