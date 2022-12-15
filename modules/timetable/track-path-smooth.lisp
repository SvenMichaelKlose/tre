(defclass (track-path-smooth track-path) (elm fx fy fz tx ty tz)
  (super elm fx fy fz tx ty tz)
  this)

(defmethod track-path-smooth set (a)
  (track-path-set (* 100 (degree-sin (* a .9)))))

(finalize-class track-path-smooth)
