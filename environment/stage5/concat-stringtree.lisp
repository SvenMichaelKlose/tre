(defun %concat-stringtree (x)
  (& x
     (? (string? x)
        x
        (apply #'string-concat (@ #'%concat-stringtree x)))))

(defun concat-stringtree (&rest x)
  (%concat-stringtree x))
