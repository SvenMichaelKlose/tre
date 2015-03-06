; tré – Copyright (c) 2009–2010,2012–2015 Sven Michael Klose <pixel@copei.de>

(defmacro bind-event-methods (&rest event-types)
  `(progn
     ,@(@ [`(*event-module*.hook ,(downcase (symbol-name _))
                                 (bind (slot-value this ',($ '_ _))))]
          event-types)))

(defmacro bind-event-methods-element (elm &rest event-types)
  `(progn
     ,@(@ [`(*event-module*.hook ,(downcase (symbol-name _))
                                 (bind (slot-value this ',($ '_ _)))
                                 ,elm)]
          event-types)))
