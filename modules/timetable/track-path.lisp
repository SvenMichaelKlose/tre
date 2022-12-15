(fn distance-percent (fx fy fz tx ty tz p)
  (values (+ fx (percent (- tx fx) p))
          (+ fy (percent (- ty fy) p))
          (+ fz (percent (- tz fz) p))))

(defclass track-path (elm fx fy fz tx ty tz)
  (super elm fx fy fz tx ty tz)
  this)

(defmember track-path
  _elm _fx _fy _fz _tx _ty _tz)

(defmethod track-path track-path-set (p)
  (with ((x y z) (distance-percent _fx _fy _fz _tx _ty _tz p))
    (_elm.set-position x y z))
  (_elm.update))

(defmethod track-path set (a)
  (track-path-set a))

(defmethod track-path clear ()
  (_elm.clear))

(finalize-class track-path)
