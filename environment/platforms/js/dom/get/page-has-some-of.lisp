;;;;; tré – Copyright (c) 2009-2010,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun page-has-some-of (root lst)
 (dolist (cls (ensure-list lst))
   (& (root.get-first-by-class cls)
      (return t))))
