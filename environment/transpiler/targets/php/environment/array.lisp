;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate *arrays* is_array g a s p r keys)

(defun array? (x)
  (| (is_a x "__array")
     (is_array x)))

(defun %array-push (arr x)
  (%setq (%%native "$" arr "[]") x)
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
      (%setq (%%native "$" a "[]") !))))

(defun aref (a k)
  (href a k))

(defun (= aref) (v a k)
  (=-href v a k))
