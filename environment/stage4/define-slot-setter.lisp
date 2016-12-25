(defmacro define-slot-setter-macro (macro-name op &rest vals)
  `(defmacro ,macro-name (name obj slot)
    `(defun ,,name (,,obj ,@vals)
       (,op ,@vals ,,slot))))

(define-slot-setter-macro define-slot-setter-acons! acons! key value)
(define-slot-setter-macro define-slot-setter-push push value)
(define-slot-setter-macro define-slot-setter-append append params)
