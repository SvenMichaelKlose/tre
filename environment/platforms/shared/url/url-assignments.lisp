;;;;; tré – Copyright (c) 2012–2014 Sven Michael Klose <pixel@copei.de>

(defun url-assignment (name val)
  (string-concat (downcase (symbol-name name)) "=" val))

(defun url-assignments (x)
  (alist-assignments x :padding "&"))

(defun url-assignments-tail (x)
  (? x
     (+ "?" (url-assignments x))
     ""))
