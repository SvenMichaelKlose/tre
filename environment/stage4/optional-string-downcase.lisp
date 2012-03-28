;;;;; tré - Copyright (c) 2009,2012 Sven Michael Klose <pixel@copei.de>

(defun optional-string-downcase (x &key (convert? nil))
  (? convert?
     (string-downcase x)
	 x))
