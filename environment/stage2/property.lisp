(fn props-alist (x)
  (filter [. _ (slot-value x _)]
          (keys x)))

(fn props-keywords (x)
  (+@ [list (make-keyword (upcase _)) (slot-value x _)]
      (keys x)))

(fn alist-props (x)
  (& x
     (aprog1 (new)
       (@ (i x)
         (= (slot-value ! i.) .i)))))

(fn merge-props (a b)
  (aprog1 (new)
    (@ (i (keys a))
      (= (slot-value ! i) (slot-value a i)))
    (@ (i (keys b))
      (= (slot-value ! i) (slot-value b i)))))

(fn copy-props (x)
  (merge-props x nil))

(fn add-props (x &rest props)
  (merge-props x (*> #'make-json-object props)))

(fn remove-props (props &rest names)
  (aprog1 (new)
    (@ (i (keys props))
      (| (member i names)
         (= (slot-value ! i) (slot-value props i))))))

(fn property-values (x)
  (filter [slot-value x _] (keys x)))
