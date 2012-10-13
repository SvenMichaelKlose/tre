;;;;; Caroshi – Copyright (c) 2009–2010,2012 Sven Michael Klose <pixel@copei.de>

(defun alist-assignments (x &key (padding ", ") (quoting "\""))
  (apply #'+ (pad (mapcar #'((k v)
                              (+ k "=" quoting (escape-string (string v) #\") quoting))
                          (symbol-names (carlist x) :downcase? t)
                          (cdrlist x))
                  padding)))
