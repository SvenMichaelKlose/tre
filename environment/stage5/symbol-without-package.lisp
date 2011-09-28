;;;;; tré - Copyright (c) 2011 Sven Klose <pixel@copei.de>

(defun symbol-without-package (x)
  (aif (symbol? x)
       (make-symbol (symbol-name x))
       x))
