(defclass (attribute-store store) (&key element fields (prefix nil))
  (super)
  (= _element element)
  (= _fields fields)
  (= _prefix prefix)
  (_fetch))

(defmember attribute-store
    _element
    _fields
    _prefix)

(defmethod attribute-store _attribute-name (x)
  (string-concat (!? _prefix ! "") x))

(defmethod attribute-store _fetch ()
  (@ (i _fields data)
    (& (_element.attr? (_attribute-name i))
       (= (aref data i) (_element.attr (_attribute-name i))))))

(defmethod attribute-store commit ()
  (@ (i _fields)
    (_element.attr (_attribute-name i) (aref data i))))

(finalize-class attribute-store)
