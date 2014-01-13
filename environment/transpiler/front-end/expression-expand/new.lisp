(defun expex-arg (x)
  (? (movable-arg? x)
     (with-expex-sym g
       (. g `(%= ,g ,x)))))

(define-filter expex-args (x)
  (expex-arg x))

(defun expex-%= (x)
  (? (atomic? (%=-value x))
     (list x)
     (alet (expex-args x)
       (expex-expr (+ (cdrlist !)
                      `((,(car (%=-value x)) ,(carlist !))))))))

(defun expex-expr (x)
  (& x
     (?
       (%=? x)            (expex-%= x)
       (%%block? x)       (expex-%%block x)
       (named-lambda? x)  (copy-lambda x (expression-expand (lambda-body x)))
       (list x)))

(defun expression-expand (x)
  (make-return-value (mapcan #'expex-expr x)))
