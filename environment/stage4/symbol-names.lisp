;;;;; tré – Copyright (c) 2012–2013 Sven Michael Klose <pixel@copei.de>

(defun symbol-names (x &key (downcase? nil))
  (filter [? (symbol? _)
             (funcall (? downcase?
                         #'string-downcase
                         #'identity)
                      (symbol-name _))
             _]
          x))

(defun symbol-names-string (x &key (downcase? nil))
  (apply #'string-concat (pad (symbol-names x :downcase? downcase?) " ")))
