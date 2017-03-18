(var *js-array-constructor* (make-array).constructor)

(fn aref (a k)      (%%%aref a k))
(fn =-aref (v a k)  (%%%=-aref v a k))

(defmacro aref (a k)     `(%%%aref ,a ,k))
(defmacro =-aref (v a k) `(%%%=-aref ,v ,a ,k))

(fn array? (x)
  (& x (eq *js-array-constructor* x.constructor)))

(fn list-array (x)
  (!= (make-array)
    (@ (i x !)
      (!.push i))))
