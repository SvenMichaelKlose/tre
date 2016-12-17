; tré – Copyright (c) 2010–2014,2016 Sven Michael Klose <pixel@copei.de>

(defun path-append (dir &rest path-components)
  (@ (x (remove-if #'not path-components) dir)
    (= dir (+ (trim-tail dir "/") "/" (trim x "/")))))
