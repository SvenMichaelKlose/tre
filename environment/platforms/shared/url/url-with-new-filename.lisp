(defun url-with-new-filename (path new-name)
  (+ (? (eql "" path)
	    ""
		(url-without-filename path))
     "/"
     new-name))
