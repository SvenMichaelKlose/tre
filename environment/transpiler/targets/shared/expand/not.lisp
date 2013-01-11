;;;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

(defun shared-not (x)
   `(? ,x. nil ,(!? .x
                    (shared-not !)
                    t)))
