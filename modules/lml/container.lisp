(defclass (lml-container lml-component) (init-props)
  (super init-props)
  (= state props.store.data)
  this)

(defmethod lml-container component-will-update ()
  (props.store.write state))

(finalize-class lml-container)
