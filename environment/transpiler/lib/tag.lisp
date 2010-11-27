;;;;; TRE compiler
;;;;; Copyright (c) 2006-2010 Sven Klose <pixel@copei.de>

(defvar *compiler-tag-counter* 1)

(defun make-compiler-tag ()
  (incf *compiler-tag-counter*))

(defmacro with-compiler-tag (l &rest body)
  `(let ,l (make-compiler-tag)
     ,@body))
