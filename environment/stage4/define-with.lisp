;;;;; tré - Copyright (c) 2008,2012 Sven Michael Klose <pixel@copei.de>

(defmacro define-with (name what)
  `(defmacro ,name (x &body body)
	 `(let ,,x ,what
        ,,@body)))
