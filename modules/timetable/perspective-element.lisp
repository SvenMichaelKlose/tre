(defclass (perspective-element perspective) (width height elm)
  (super)
  (document.body.add elm)
  (_init-element elm width height)
  this)

(finalize-class perspective-element)
