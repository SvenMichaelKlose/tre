;;;;; tré – Copyright (c) 2009,2014 Sven Michael Klose <pixel@copei.de>

(defun assoc-url (x)
  (concat-stringtree
	(? x "?" "")
    (pad (mapcar (fn (list (encode-u-r-i-component _.)
					  "="
					  (encode-u-r-i-component ._)))
		  	     x)
	     "&")))
