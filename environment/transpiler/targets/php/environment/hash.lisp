;;;;; tré – Copyright (c) 2009,2011–2012 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate is_a)

(defun %%key (x)
  (?
    (is_a x "__symbol") (%%%string+ "~%S" x.n)
    (is_a x "__cons") (%%%string+ "~%L" x.id)
    (is_a x "__array") (%%%string+ "~%A" x.id)
    (is_a x "__character") (%%%string+ "~%C" x.v)
    x))

(defun hash-table? (x)
  (is_a x "__l"))

(defun hash-assoc (x)
  (let lst nil
    (map (fn nconc! lst `((, _ ,(href x _)))) x)
    lst))

(defun hash-merge (a b)
  (unless a
    (= a (make-hash-table)))
  (dolist (k (hashkeys b) a)
    (= (href a k) (href b k))))
