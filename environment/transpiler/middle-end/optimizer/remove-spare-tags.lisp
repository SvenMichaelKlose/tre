(fn has-no-jumps-to? (x tag)
  (notany [& (some-%go? _)
             (== (%go-tag _) tag)]
          x))

(fn tags-lambda (body)
  (!= (remove-if-not [has-no-jumps-to? body _]
                     (remove-if-not #'number? body))
    (remove-if [member _ !] body)))

(define-optimizer remove-spare-tags
  (named-lambda? a)
    (. (copy-lambda x :body (remove-spare-tags (tags-lambda (lambda-body x))))
       (remove-spare-tags d)))
