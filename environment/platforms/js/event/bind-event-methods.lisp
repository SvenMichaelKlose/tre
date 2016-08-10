; tré – Copyright (c) 2009–2010,2012–2016 Sven Michael Klose <pixel@copei.de>

(defmacro bind-event-methods (event-module &rest event-types)
  `(progn
     ,@(@ [`((slot-value ,event-module 'hook) ,(downcase (symbol-name _))
                                              (bind (slot-value this ',($ '_ _))))]
          event-types)))

(defmacro bind-event-methods-element (event-module elm &rest event-types)
  `(progn
     ,@(@ [`((slot-value ,event-module 'hook) ,(downcase (symbol-name _))
                                              (bind (slot-value this ',($ '_ _)))
                                              ,elm)]
          event-types)))
