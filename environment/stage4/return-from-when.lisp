;;;; TRE environment
;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defmacro return-from-when (block-name x)
  `(awhen ,x
	 (return-from ,block-name !)))
