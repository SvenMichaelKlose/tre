(defun %princ (txt &optional (only-standard-output nil))
  (%= nil (echo txt))
  txt)
