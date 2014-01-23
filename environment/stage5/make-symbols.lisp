;;;;; tré – Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

(defun make-symbols (x &key (upcase? nil))
  (filter [make-symbol (funcall (? upcase? #'upcase #'identity) _)] x))
