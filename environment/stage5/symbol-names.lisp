;;;;; Caroshi – Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

(defun symbol-names (x &key (downcase? nil))
  (filter (fn ? (symbol? _)
                (funcall (? downcase?
                            #'string-downcase
                            #'identity)
                         _)
                _)
          x))
