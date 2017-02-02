(defun array? (x)
  (| (is_a x "__array")
     (is_array x)))

(defun %array-push (arr x)
  (%= (%%native "$" arr "[]") x)
  x)

(defun array-push (arr x)
  (? (is_a x "__array")
     (arr.p x)
     (%array-push arr x))
  x)

(defun list-array (x)
  (let a (make-array)
    (@ (i x a)
      (a.p i))))

(defun list-phphash (x)
  (let a (%%%make-hash-table)
    (@ (i x a)
      (%= (%%native "$" a "[]") i))))

(defun aref (a k)
  (? (is_array a)
     (php-aref a k)
     (href a k)))

(defun (= aref) (v a k)
  (? (is_array a)
     (=-php-aref v a k)
     (=-href v a k)))
