;;;;; tré – Copyright (c) 2009,2011–2012 Sven Michael Klose <pixel@copei.de>

(defun + (&rest x)
  (apply (?
           (string? x.) #'string-concat
           (| (not x.) (cons? x.)) #'append
           #'number+)
         x))

(defun - (&rest x)
  (apply #'number- x))
