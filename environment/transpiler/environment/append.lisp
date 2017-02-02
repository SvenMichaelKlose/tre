(functional append)

(fn append (&rest lists)    ; TODO: Cleanup.
  (when lists
    (let f nil
      (let l nil
        (@ (i lists f)
          (when i
            (? l
               (setq l (last (rplacd l (copy-list i))))
               (setq f (copy-list i)
                     l (last f)))))))))
