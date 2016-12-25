(defvar *default-listprop* nil)

(defnative cons (x y)
  (new __cons x y))
