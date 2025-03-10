(fn gather-imports-list (x)
  (@ (i x)
    (? (cons? i)
       (gather-imports-list i)
       (when (symbol? i)
         (add-wanted-function i)
         (add-wanted-variable i)))))

(metacode-walker gather-imports (x)
  :if-%=
    (with-%= place value x.
      (add-wanted-variable place)
      (gather-imports-list (ensure-list value))
      (list x.)))
