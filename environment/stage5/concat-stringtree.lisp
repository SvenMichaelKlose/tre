; tré – Copyright (c) 2008–2009,2016 Sven Klose <pixel@copei.de>

(defun %concat-stringtree (x)
  (& x
     (? (string? x)
        x
        (apply #'string-concat (@ #'%concat-stringtree x)))))

(defun concat-stringtree (&rest x)
  (%concat-stringtree x))
