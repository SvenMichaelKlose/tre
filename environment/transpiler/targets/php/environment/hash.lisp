;;;;; tré – Copyright (c) 2009,2011–2012 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate is_a)

(defun %%key (x)
  (?
    (is_a x "__symbol") (%%%string+ "~%S" x.n "~P" x.p)
    (is_a x "__cons") (%%%string+ "~%L" x.id)
    (is_a x "__array") (%%%string+ "~%A" x.id)
    (is_a x "__character") (%%%string+ "~%C" x.v)
    x))

(defun hash-table? (x)
  (is_a x "__l"))

(defun hash-merge (a b)
  (unless a
    (= a (make-hash-table)))
  (dolist (k (hashkeys b) a)
    (= (href a k) (href b k))))

(defun hashkeys (x)
  (maparray #'identity (phparray-hashkeys x)))

(defun hash-assoc (x)
  (filter (fn cons _ (href x _)) (hashkeys x)))
