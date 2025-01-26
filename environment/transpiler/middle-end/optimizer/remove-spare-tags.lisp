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

(define-optimizer remove-spare-tags
  (named-lambda? a)
    (. (remove-spare-tags-body a)
       (remove-spare-tags d)))
