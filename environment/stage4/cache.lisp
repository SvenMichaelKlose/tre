;;;;; tré – Copyright (c) 2010,2012 Sven Michael Klose <pixel@copei.de>

(defmacro cache (val place)
  `(or ,place
	   (and (= ,place ,val)
		    nil)))
