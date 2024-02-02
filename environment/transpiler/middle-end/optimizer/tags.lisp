(fn two-subsequent-tags? (a d)
  (& a (atom a)
     d. (atom d.)))

(fn has-no-jumps-to? (x tag)
  (notany [& (some-%go? _)
             (== (%go-tag _) tag)]
          x))

(fn tags-lambda (x)
  (with (body        x
         spare-tags  (remove-if-not [has-no-jumps-to? body _]
                                    (remove-if-not #'number? x)))
    (remove-if [member _ spare-tags] x)))

(fn remove-spare-tags-body (x)
  (copy-lambda x :body (remove-spare-tags (tags-lambda (lambda-body x)))))

(fn remove-spare-tags (x)
  (with-cons a d x
     (. (? (named-lambda? a)
           (remove-spare-tags-body a)
           a)
        (remove-spare-tags d))))
   
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
    (remove-spare-tags (translate-tags (reduce-tags statements)))))
