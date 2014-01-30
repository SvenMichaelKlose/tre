;;;;; tré – Copyright (c) 2010–2014 Sven Michael Klose <pixel@copei.de>

(defun path-append (dir fil)
  (? (empty-string? dir)
     fil
  	 (+ (trim-tail dir "/")
        "/"
        (trim fil "/"))))
