;;;;; tré – Copyright (c) 2005–2014 Sven Michael Klose <pixel@copei.de>

(defun mapcar (func &rest lists)
  (let args (%map-args lists)
    (& args
       (cons (apply func args)
             (apply #'mapcar func lists)))))
