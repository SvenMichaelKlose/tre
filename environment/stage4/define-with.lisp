;;;;; Caroshi ECMAScript library
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

(defmacro define-with (name what)
  `(defmacro ,name (x &rest body)
	 `(let ,,x ,what
        ,,@body)))
