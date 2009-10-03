;;;;; TRE environment
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defmacro remove! (x lst &rest args)
  `(setf ,lst (remove ,x ,lst ,@args)))
