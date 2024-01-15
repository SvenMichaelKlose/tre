(defclass (lml-container lml-component) (attrs)
  (super attrs)
  (= state props.store.data))

(defmethod lml-container component-will-update ()
  (props.store.write state))

(finalize-class lml-container)
