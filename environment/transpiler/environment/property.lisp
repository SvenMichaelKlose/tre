(fn properties-alist (x)
  (@ [. _ (%aref x _)] (property-names x)))

(fn alist-properties (x)
  (& x
     (aprog1 (new)
       (@ [=-%aref ._ ! _.] x))))

(fn merge-properties (a b)
  (aprog1 (new)
    (@ (i (property-names a))
      (=-%aref (%aref a i) ! i))
    (@ (i (property-names b))
      (=-%aref (%aref b i) ! i))))

(fn copy-properties (x)
  (merge-properties x nil))

(fn update-properties (x &rest props)
  (merge-properties x (apply #'make-object props)))
