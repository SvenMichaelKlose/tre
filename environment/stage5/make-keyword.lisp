; tré – Copyright (c) 2011–2012,2016 Sven Michael Klose <pixel@copei.de>

(define-filter make-keywords (x)
  (make-keyword x))

(defun make-keyword (x)
  (& x
     (make-symbol (? (symbol? x)
                     (symbol-name x)
                     x)
               *keyword-package*)))
