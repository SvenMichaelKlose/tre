; tré – Copyright (c) 2008,2016 Sven Michael Klose <pixel@copei.de?

(defmacro assert (x &optional (txt "") &rest args)
  (when *assert?*
	(make-assertion x txt args)))
