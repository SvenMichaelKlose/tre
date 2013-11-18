;;;;; tré – Copyright (c) 2009–2011 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate location)

(defun document-location (&optional (doc document))
  (pathlist-path (butlast (path-pathlist (location-string doc.location)))))
