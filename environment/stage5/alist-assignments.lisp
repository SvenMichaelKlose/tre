;;;;; Caroshi – Copyright (c) 2009–2010 Sven Michael Klose <pixel@copei.de>

(defun alist-assignments (x)
  (apply #'+ (comma-separated-list (mapcar #'((k v)
                                               (+ k "=\"" (escape-string v #\") "\""))
                                           (symbol-names (carlist x) :downcase? t)
                                           (cdrlist x)))))
