(defclass track-pause ())
(defmethod track-pause set (a))
(defmethod track-pause clear ())
(finalize-class track-pause)
