(defclass store (&optional (init-data (new)))
  (= data       init-data
     _children  (new))
  this)

(defmember store
    data
    _children
    _component)

(defmethod store _update-component ()
  (!? _component
      (!.force-update)))

(defmethod store _store-write (new-data)
  (prog1 (= data (merge-props data new-data))
    (_update-component)))

(defmethod store names ()
  (keys data))

(defmethod store connect (comp)
  (= _component comp))

(defmethod store value (name)
  (aref data name))

(defmethod store child (name)
  (| (aref _children name)
     (= (aref _children name) (new child-store :name name :parent this))))

(defmethod store write (new-data)
  (_store-write new-data))

(defmethod store replace (new-data)
  (prog1 (= data (copy-props new-data))
    (_update-component)))

(defmethod store empty ()
  (prog1 (= data nil)
    (_update-component)))

(defmethod store commit ()
  data)

(defmethod store set-schema-defaults (schema)
  (@ (i (keys schema))
    (!? (& (not (aref data i))
           (aref schema i).default)
        (= (aref data i) !))))

(finalize-class store)


(defclass (child-store store) (&key name parent)
  (super (copy-props (aref parent.data name)))
  (= _name name
     _parent parent)
  this)

(defmember child-store
    _name
    _parent)

(defmethod child-store _update-parent ()
  (_parent.write (make-object _name data)))

(defmethod child-store write (new-data)
  (prog1 (_store-write new-data)
    (_update-parent)))

(defmethod child-store replace (new-data)
  (prog1 (= data (copy-props new-data))
    (_update-parent)))

(defmethod child-store empty ()
  (prog1 (= data nil)
    (_update-parent)))

(defmethod child-store commit ()
  (_parent.commit))

(finalize-class child-store)
