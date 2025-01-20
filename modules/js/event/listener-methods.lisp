(fn make-listener-methods (class-name)
  (@ [`(defmethod ,class-name ,(make-symbol (upcase _)) (fun)
         ((%slot-value this add-event-listener) ,_ fun))]
     *all-events*))
