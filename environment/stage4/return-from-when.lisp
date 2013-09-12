;;;;; tré – Copyright (c) 2009,2013 Sven Michael Klose <pixel@copei.de>

(defmacro return-from-when (block-name x)
  `(!? ,x
	   (return-from ,block-name !)))

(defmacro return-when (x)
  `(!? ,x
	   (return !)))
