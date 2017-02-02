(fn location-string (loc)
  (unescape (new *string loc)))

(fn document-location (&optional (doc document))
  (pathlist-path (butlast (path-pathlist (location-string doc.location)))))
