;;;;; tré - Copyright (c) 2010,2012 Sven Michael Klose <pixel@copei.de>

(defmacro if (predicate &body x)
  `(? ,predicate ,@x))

(defmacro aif (predicate &body x)
  `(!? ,predicate ,@x))
