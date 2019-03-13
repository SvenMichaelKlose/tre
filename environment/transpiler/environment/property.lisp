(fn properties-alist (x)
  (@ [. _ (slot-value x _)] (property-names x)))

(fn alist-properties (x)
  (& x
     (aprog1 (new)
       (@ (i x)
         (= (slot-value ! i.) .i)))))

(fn merge-props (a b)
  (aprog1 (new)
    (@ (i (property-names a))
      (= (slot-value ! i) (slot-value a i)))
    (@ (i (property-names b))
      (= (slot-value ! i) (slot-value b i)))))

(fn copy-properties (x)
  (merge-props x nil))

(fn add-properties (x &rest props)
  (merge-props x (apply #'make-object props)))

(fn remove-property (props key)
  (aprog1 (new)
    (@ (i (property-names props))
      (| (eql i key)
         (= (slot-value ! i) (slot-value props i))))))
