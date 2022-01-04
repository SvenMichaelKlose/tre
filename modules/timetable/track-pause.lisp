;;;;; Caroshi
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defclass track-pause ()
  this)

(defmethod track-pause set (a))
(defmethod track-pause clear ())

(finalize-class track-pause)
