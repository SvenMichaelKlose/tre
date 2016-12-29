(= (symbol-function 'cons) "tre_cons")

(defun car (x)
  (& x x.a))

(defun cdr (x)
  (& x x.d))

(defun rplaca (x val)
  (= x.a val)
  x)

(defun rplacd (x val)
  (= x.d val)
  x)

(defun cons? (x)
  (is_a x "__cons"))
