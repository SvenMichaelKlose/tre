;;;;; TRE environment
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun optional-string-downcase (x &key (convert? nil))
  (if convert?
	  (string-downcase x)
	  x))
