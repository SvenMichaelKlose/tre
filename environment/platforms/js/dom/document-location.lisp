(defun location-string (loc)
  (unescape (new *string loc)))

(defun document-location (&optional (doc document))
  (pathlist-path (butlast (path-pathlist (location-string doc.location)))))
