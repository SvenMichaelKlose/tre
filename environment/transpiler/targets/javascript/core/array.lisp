(fn list-array (x)
  (!= (make-array)
    (@ (i x !)
      (%native ! ".push (" i ")"))))

(fn array (&rest elms)
  (list-array elms))

(fn aref (a k)            (%aref a k))
(fn =-aref (v a k)        (=-%aref v a k))
(fn array? (x)            (*array.is-array x))

(defmacro array (&rest x)  `(%make-array ,@x))
(defmacro aref (a k)       `(%aref ,a ,k))
(defmacro =-aref (v a k)   `(=-%aref ,v ,a ,k))
(defmacro array? (x)       `(*array.is-array ,x))
