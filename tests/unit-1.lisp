(defclass a ()
  this)

(defmethod a bla ()
  (identity 'a))

(finalize-class a)

(defclass (b a) ()
  this)

(finalize-class b)

(| (eq 'a ((new b).bla))
   (error "Class B: BLA was not inherited from class A."))
