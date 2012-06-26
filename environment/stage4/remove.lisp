;;;;; tré – Copyright (c) 2009,2012 Sven Michael Klose <pixel@copei.de>

(defmacro remove! (x lst &rest args)
  `(= ,lst (remove ,x ,lst ,@args)))
