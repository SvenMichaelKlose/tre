;;;; TRE environment
;;;; Copyright (C) 2005-2008 Sven Klose <pixel@copei.de>

(defmacro clr (&rest places)
  `(setf ,@(mapcan #'((x)
                        `(,x nil))
                   places)))
