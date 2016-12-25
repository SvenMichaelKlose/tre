;;;;; tré – Copyright (c) 2009–2011,2013 Sven Michael Klose <pixel@copei.de>

(defun location-string (loc)
  (unescape (new *string loc)))

(defun document-location (&optional (doc document))
  (pathlist-path (butlast (path-pathlist (location-string doc.location)))))
