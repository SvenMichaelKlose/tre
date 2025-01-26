(defclass a ())

(defmember a (:protected stayingvalue))

(defmethod a bla ()
  (identity 'a))

(finalize-class a)

(defclass (b a) ()
  (super))

(finalize-class b)

(| (eq 'a ((new b).bla))
   (error "Class B: BLA was not inherited from class A."))
