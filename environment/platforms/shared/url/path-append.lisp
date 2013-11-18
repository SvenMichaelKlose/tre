;;;;; tré – Copyright (c) 2010–2013 Sven Michael Klose <pixel@copei.de>

(defun path-append (dir fil)
  (? (empty-string? dir)
     fil
  	 (+ (trim-tail #\/ dir :test #'character==) "/" (trim #\/ fil :test #'character==))))
