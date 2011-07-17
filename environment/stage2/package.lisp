;;;;; TRE tree processor
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

(defun make-package (name)
  (unless (package? name)
    (error "package ~A is already defined"))
  (%set-atom-fun name (%make-package)))

(defmacro defpackage (name &rest exports)
  (with (pkg (make-package name))
	(map (fn make-symbol _ pkg t) exports)))

(defmacro use-package (name &rest-imports)
  (with (pkg (symbol-function name))
    (map (fn (with (n (symbol-name _))
			   (make-symbol n nil (make-symbol _ pkg))))
	     imports)))
