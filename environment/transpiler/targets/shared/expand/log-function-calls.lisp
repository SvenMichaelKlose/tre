;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defvar *log-functions?* nil)

(defmacro log-functions (x)
  (setf *log-functions?* x)
  nil)
