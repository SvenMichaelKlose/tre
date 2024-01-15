(defclass (track-path-ellipsis track-path) (elm fx fy fz tx ty tz r)
  (super elm fx fy fz tx ty tz)
  (= _r r))
;        _rg (integer (sqrt (+ (pow (- _tx _fx)) (pow (- _ty _fy))))))
;  (with ((x y z) (distance-percent fx fy fz tx ty tz 50))
;    (= _x x _y y _z z))

(defmember track-path-ellipsis _r _rg _x _y _z)

(defmethod track-path-ellipsis set (a)
  (_elm.set-position (+ _fx (percent (- _tx _fx) a))
                     (+ _fy (percent (- _ty _fy) a))
                     (circle-position _fz _tz _r a (degree-sin (* a 1.8))))
  (_elm.update))

(defmethod track-path-ellipsis clear ()
  (_elm.clear))

(finalize-class track-path-ellipsis)
