;;;;; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(defun %expex-argument-expand-rest (args)
  (& args
     `(. ,args. ,(%expex-argument-expand-rest .args))))

(defun expex-argument-expand (fun def vals)
  (filter [? (& (cons? _)
                (argument-rest-keyword? _.))
             (%expex-argument-expand-rest ._)
             _]
          (cdrlist (argument-expand fun def vals))))
