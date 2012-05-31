;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defun %expex-argument-expand-rest (args)
  (when args
    `(cons ,args.
           ,(%expex-argument-expand-rest .args))))

(defun expex-argument-expand (fun def vals)
  (mapcar (fn ? (and (cons? _)
                     (argument-rest-keyword? _.))
                (%expex-argument-expand-rest ._)
                _)
          (cdrlist (argument-expand fun def vals t))))
