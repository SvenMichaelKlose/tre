(defmacro add-listener-methods (elm &rest event-types)
  "For use in constructors or methods. Can only be used once per instance."
  `(progn
     ,@(@ [`((slot-value ,elm 'add-event-listener)
               ,(downcase (symbol-name _))
               (= (slot-value this ',($ '_ _))
                    ((slot-value (slot-value this ',($ '_ _)) 'bind) this)))]
          event-types)))

(defmacro remove-listener-methods (elm &rest event-types)
  "For use in constructors or methods. Can only be used once per instance."
  `(progn
     ,@(@ [`(progn
              ((slot-value ,elm 'remove-event-listener)
                 ,(downcase (symbol-name _))
                 ((slot-value (slot-value this ',($ '_ _)) 'bind) this))
              (= (slot-value this ',($ '_ _)) nil))]
          event-types)))
