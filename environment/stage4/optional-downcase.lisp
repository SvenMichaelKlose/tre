(defun optional-downcase (x &key (convert? nil))
  (? convert?
     (downcase x)
	 x))
