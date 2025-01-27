(fn two-subsequent-tags? (a d)
  (& a (atom a)
     d. (atom d.)))

(fn optimize-tags (statements)
  (with (removed-tags nil
         replace-tag
           #'((old-dest new-dest)
               (= removed-tags (@ [? (eq ._ old-dest)
                                     (. _. new-dest)
                                     _]
                                  removed-tags)))

         add-removed-tag
           #'((old-tag new-tag)
               (replace-tag old-tag new-tag)
               (acons! old-tag new-tag removed-tags))

         reduce-tags
           #'((x)
               (optimizer reduce-tags
                 (two-subsequent-tags? a d)
                   (progn
                     (add-removed-tag a d.)
                     (reduce-tags d))
                 (& (number? a)
                    (%go? d.))
                   (progn
                     (add-removed-tag a (%go-tag d.))
                     (reduce-tags d))))

         translate-tag
           [| (assoc-value _ removed-tags) _]

         translate-tags
           #'((x)
               (optimizer translate-tags
                 (some-%go? a)
                   (. `(,a. ,(translate-tag .a.) ,@..a)
                      (translate-tags d))
                 (number? a)
                   (. (translate-tag a)
                      (translate-tags d)))))
    (translate-tags (reduce-tags statements))))
