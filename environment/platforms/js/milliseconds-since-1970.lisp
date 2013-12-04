;;;;; tré – Copyright (c) 2011–2012 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate *date get-time)

(defun milliseconds-since-1970 ()
  ((new *date).get-time))
