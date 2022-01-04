(defmacro add-listener-methods (elm &rest event-types)
  `(progn
     ,@(@ [`((slot-value ,elm 'add-event-listener) ,(downcase (symbol-name _))
                                                   (= (slot-value this ',($ '_ _)) (bind (slot-value this ',($ '_ _))))
                                                   ,elm)]
          event-types)))

(defmacro remove-listener-methods (elm &rest event-types)
  `(progn
     ,@(@ [`((slot-value ,elm 'remove-event-listener) ,(downcase (symbol-name _))
                                                      (slot-value this ',($ '_ _))
                                                      ,elm)]
          event-types)))
