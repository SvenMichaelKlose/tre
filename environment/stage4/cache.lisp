;;;;; TRE environment
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defmacro cache (val place)
  `(or ,place
	   (and (setf ,place ,val)
		    nil)))
