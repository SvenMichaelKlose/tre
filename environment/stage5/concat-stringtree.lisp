(fn %concat-stringtree (x)
  (& x
     (? (string? x)
        x
        (apply #'string-concat (@ #'%concat-stringtree x)))))

(fn concat-stringtree (&rest x)
  (%concat-stringtree x))
