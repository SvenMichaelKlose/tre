;;;;; tré - Copyright (c) 2010,2012 Sven Michael Klose <pixel@copei.de>

(defmacro ? (predicate &body x)
  `(if ,predicate ,@x))

(defmacro !? (predicate &body x)
  `(aif ,predicate ,@x))
