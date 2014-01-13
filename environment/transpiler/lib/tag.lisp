;;;;; tré – Copyright (c) 2006–2010,2012–2014 Sven Michael Klose <pixel@copei.de>

(defvar *tag-counter* 1)

(defun make-compiler-tag ()
  (++! *tag-counter*))

(defmacro with-compiler-tag (tags &rest body)
  `(with ,(mapcan [`(,_ (make-compiler-tag))]
                  (ensure-list tags))
     ,@body))
