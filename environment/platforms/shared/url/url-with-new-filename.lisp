;;;;; tré – Copyright (c) 2009–2012 Sven Michael Klose <pixel@copei.de>

(defun url-with-new-filename (path new-name)
  (+ (? (== "" path)
	    ""
		(url-without-filename path))
     "/"
     new-name))
