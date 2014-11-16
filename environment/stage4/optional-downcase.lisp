;;;;; tré - Copyright (c) 2009,2012,2014 Sven Michael Klose <pixel@copei.de>

(defun optional-downcase (x &key (convert? nil))
  (? convert?
     (downcase x)
	 x))
