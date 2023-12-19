(defclass (lml-container lml-component) (attrs)
  (super attrs)
  (= state props.store.data)
  this)

(defmethod lml-container component-will-update ()
  (props.store.write state))

(finalize-class lml-container)
