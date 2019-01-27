(fn get-definer (class)
  (? class
     `(defmethod ,class)
     '(fn)))

(defmacro define-alias (alias real &key (class nil))
  `(,@(get-definer class) ,alias ()
      ,real))

(defmacro define-get-alias (alias real &key (class nil))
  `(,@(get-definer class) ,($ 'get- alias) ()
      ,real))

(defmacro define-set-alias (alias real &key (class nil))
  `(,@(get-definer class) ,($ 'set- alias) (x)
      (= ,real x)))

(defmacro define-getset-alias (alias real &key (class nil))
  `{(define-get-alias ,alias ,real :class ,class)
	(define-set-alias ,alias ,real :class ,class)})
