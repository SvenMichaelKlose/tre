(fn optional-downcase (x &key (convert? nil))   ; TODO: Reconsider.
  (? convert?
     (downcase x)
	 x))
