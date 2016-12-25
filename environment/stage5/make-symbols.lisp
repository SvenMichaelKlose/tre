(defun make-symbols (x &key (upcase? nil))
  (@ [make-symbol (funcall (? upcase? #'upcase #'identity) _)] x))
