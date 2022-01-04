(fn line-up-circle-tracks (timetables elements duration from-z to-z revolutions &optional (offset 0))
  (with (num  (length elements)
         deg  (* 360 offset))
    (@ #'((tt url)
           (tt.add duration (new track-circle
                            (new perspective-image url)
                            0 0 from-z
                            400 deg
                            0 0 to-z
                            400 (+ (* 360 revolutions) deg )))
           (+! deg (/ 360 num)))
       timetables
       elements))
  timetables)
