(defmacro bind-event-methods (event-module &rest event-types)
  `{,@(@ [`((slot-value ,event-module 'hook) ,(downcase (symbol-name _))
                                             (bind (slot-value this ',($ '_ _))))]
         event-types)})

(defmacro bind-event-methods-element (event-module elm &rest event-types)
  `{,@(@ [`((slot-value ,event-module 'hook) ,(downcase (symbol-name _))
                                             (bind (slot-value this ',($ '_ _)))
                                             ,elm)]
         event-types)})
