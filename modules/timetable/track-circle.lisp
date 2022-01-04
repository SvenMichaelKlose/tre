(defclass track-circle (elm fx fy fz fr fd tx ty tz tr td)
  (= _elm elm
     _fx fx _fy fy _fz fz _fr fr _fd fd
     _tx tx _ty ty _tz tz _tr tr _td td)
  this)

(defmember track-circle
  _elm _fx _fy _fz _fr _fd _tx _ty _tz _tr _td)

(fn circle-position (from to r p d)
  (+ from (percent (- to from) p) (* r d)))

(defmethod track-circle set (p)
  (with (r  (+ _fr (percent (- _tr _fr) p))
         d  (+ _fd (percent (- _td _fd) p)))
    (_elm.set-position (circle-position _fx _tx r p (degree-sin d))
                       (circle-position _fy _ty r p (degree-cos d))
                       (+ _fz (percent (- _tz _fz) p)))
    (_elm.update)))

(defmethod track-circle clear ()
  (_elm.clear))

(finalize-class track-circle)
