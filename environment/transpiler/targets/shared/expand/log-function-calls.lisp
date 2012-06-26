;;;;; tré – Copyright (c) 2010,2012 Sven Michael Klose <pixel@copei.de>

(defvar *log-functions?* nil)

(defmacro log-functions (x)
  (= *log-functions?* x)
  nil)
