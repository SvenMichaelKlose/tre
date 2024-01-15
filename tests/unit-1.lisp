(defclass a ())
(defmethod a bla ()
  (identity 'a))
(finalize-class a)

(defclass (b a) ())
(finalize-class b)

(| (eq 'a ((new b).bla))
   (error "Class B: BLA was not inherited from class A."))
