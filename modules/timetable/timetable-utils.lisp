(fn start-timetables (timetables)
  (@ (i timetables)
    (= i._done? nil)
    (i.start)))

(fn update-timetables (timetables)
  (@ (i timetables)
    (unless (i.done?)
      (i.update))))

(fn timetables-done? (timetables)
  (every [_.done?] timetables))
