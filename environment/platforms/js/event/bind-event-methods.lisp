;;;;; tré – Copyright (c) 2009–2010,2012 Sven Michael Klose <pixel@copei.de>

(defmacro bind-event-methods (module &rest event-types)
  `(progn
     ,@(mapcar (fn `((slot-value ,module 'hook)
						,(string-downcase (symbol-name _))
						(bind (slot-value this ',($ '_ _)))))
			   event-types)))

(defmacro bind-event-methods-element (module elm &rest event-types)
  `(progn
     ,@(mapcar (fn `((slot-value ,module 'hook)
						,(string-downcase (symbol-name _))
						(bind (slot-value this ',($ '_ _)))
						,elm))
			   event-types)))
