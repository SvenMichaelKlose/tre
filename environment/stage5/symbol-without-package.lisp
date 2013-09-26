;;;;; tré - Copyright (c) 2011-2012 Sven Michael Klose <pixel@copei.de>

(defun symbol-without-package (x)
  (!? (symbol? x)
      (make-symbol (symbol-name x))
      x))

(defun symbol-without-package? (x)
  (& (symbol? x)
     (not (symbol-package x))))
