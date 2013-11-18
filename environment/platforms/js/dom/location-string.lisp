;;;;; tré – Copyright (c) 2010–2011 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate unescape *string)

(defun location-string (loc)
  (unescape (new *string loc)))
