(defun url-assignment (name val)
  (+ (downcase (symbol-name name)) "=" val))

(defun url-assignments (x)
  (alist-assignments x :padding "&"))

(defun url-assignments-tail (x)
  (& x (+ "?" (url-assignments x))))
