(define-filter make-keywords (x)
  (make-keyword x))

(defun make-keyword (x)
  (& x
     (make-symbol (? (symbol? x)
                     (symbol-name x)
                     x)
               *keyword-package*)))
