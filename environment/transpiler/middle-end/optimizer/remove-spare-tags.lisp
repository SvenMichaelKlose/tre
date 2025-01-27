(fn body-has-jumps-to? (x tag)
  (some [& (some-%go? _)
           (== tag (%go-tag _))]
        x))

(fn body-tags (x)
  (remove-if-not #'number? x))

(fn tags-lambda (body)
  (!= (remove-if [body-has-jumps-to? body _]
                 (body-tags body))
    (remove-if [member _ !] body)))

(define-optimizer remove-spare-tags
  (named-lambda? a)
    (. (copy-lambda x :body (remove-spare-tags (tags-lambda (lambda-body x))))
       (remove-spare-tags d)))
