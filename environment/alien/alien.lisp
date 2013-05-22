;;;; tré – Copyright (c) 2008–2009,2012–2013 Sven Michael Klose <pixel@copei.de>

(defvar *dl-libs* (make-hash-table :test #'string==))

(defun alien-import-lib (name)
  (cache (alien-dlopen (string-concat name))
         (href *dl-libs* name)))
