;;;;; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

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
    (adolist (x a)
      (a.p !))))

(defun list-phphash (x)
  (let a (%%%make-hash-table)
    (adolist (x a)
      (%= (%%native "$" a "[]") !))))

(defun aref (a k)
  (? (is_array a)
     (php-aref a k)
     (href a k)))

(defun (= aref) (v a k)
  (? (is_array a)
     (=-php-aref v a k)
     (=-href v a k)))
