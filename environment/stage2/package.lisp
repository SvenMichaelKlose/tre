;;;;; tré – Copyright (c) 2008,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun make-package (name)
  (unless (package? name)
    (error "Package ~A is already defined."))
  (%set-atom-fun name (%make-package)))

(defmacro defpackage (name &rest exports)
  (with (pkg (make-package name))
	(map [make-symbol _ pkg t] exports)))

(defmacro use-package (name &rest-imports)
  (with (pkg (symbol-function name))
    (map [with (n (symbol-name _))
           (make-symbol n nil (make-symbol _ pkg))]
	     imports)))
