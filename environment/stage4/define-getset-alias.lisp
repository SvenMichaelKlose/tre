(defmacro define-get-alias (alias real &key (class nil))
  `(defmethod ,class ,($ 'get- alias) ()
      ,real))

(defmacro define-set-alias (alias real &key (class nil))
  `(defmethod ,class ,($ 'set- alias) ()
      (= ,real x)))

(defmacro define-getset-alias (alias real &key (class nil))
  `{(define-get-alias ,alias ,real :class ,class)
    (define-set-alias ,alias ,real :class ,class)})
