(functional append)

(fn append (&rest lists)
  (when lists
    (let f nil
      (let l nil
        (@ (i lists f)
          (when i
            (? l
               (setq l (last (rplacd l (copy-list i))))
               (setq f (copy-list i)
                     l (last f)))))))))
