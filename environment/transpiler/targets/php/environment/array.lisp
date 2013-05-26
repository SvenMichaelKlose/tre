;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate is_array g a s p r keys)

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
    (dolist (i x a)
      (a.p i))))

(defun list-phphash (x)
  (let a (%%%make-hash-table)
    (dolist (i x a)
      (%setq (%%native "$" a "[]") i))))

(defun aref (a k)
  (href a k))

(defun (= aref) (v a k)
  (=-href v a k))
