(define-filter make-keywords (x)
  (make-keyword x))

(fn make-keyword (x)
  (& x
     (make-symbol (? (symbol? x)
                     (symbol-name x)
                     x)
                  *keyword-package*)))
