;;;;; tré – Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

(defun make-symbols (x &key (upcase? nil))
  (filter (fn make-symbol (funcall (? upcase? #'string-upcase #'identity) _)) x))
