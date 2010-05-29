;;;;; TRE environment
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defmacro ? (&rest x)
  `(if ,@x))

(defmacro !? (&rest x)
  `(aif ,@x))
