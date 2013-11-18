;;;;; tré – Copyright (c) 2009 Sven Michael Klose <pixel@copei.de>

(defun assoc-url (x)
  (concat-stringtree
	"?"
    (pad (mapcar (fn (list (encode-u-r-i-component _.)
					  "="
					  (encode-u-r-i-component ._)))
		  	     x)
	     "&")))
