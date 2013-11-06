;;;;; tré – Copyright (c) 2006–2010,2012–2013 Sven Michael Klose <pixel@copei.de>

(defvar *tag-counter* 1)

(defun make-compiler-tag ()
  (++! *tag-counter*))

(defmacro with-compiler-tag (l &rest body)
  `(let ,l (make-compiler-tag)
     ,@body))
