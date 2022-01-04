(fn play-tracks-0 (continuer timetables callback)
  (? (timetables-done? timetables)
     (funcall continuer)
     (progn
       (update-timetables timetables)
       (!? callback
           (funcall !))
       (do-wait 0
         (play-tracks-0 continuer timetables callback)))))

(fn play-tracks (continuer timetables &optional (callback nil))
  (!= (ensure-list timetables)
    (start-timetables !)
    (play-tracks-0 continuer ! callback)))
