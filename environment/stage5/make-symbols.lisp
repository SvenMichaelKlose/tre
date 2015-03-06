; tré – Copyright (c) 2012,2015 Sven Michael Klose <pixel@copei.de>

(defun make-symbols (x &key (upcase? nil))
  (@ [make-symbol (funcall (? upcase? #'upcase #'identity) _)] x))
