(defclass (perspective-canvas perspective) (width height)
  this)

(defmethod perspective-canvas init (width height)
  (with ((can ctx) (make-canvas (new :width width :height height)))
    (document.body.add can)
    (_init-element can width height)))

(finalize-class perspective-canvas)
