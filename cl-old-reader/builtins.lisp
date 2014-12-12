;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(in-package :tre-core)

(defvar *builtins* (make-hash-table :test #'eq))

(dolist (i +builtins+)
  (let ((s (find-symbol (symbol-name i) "TRE")))
    (and (fboundp s)
         (setf (gethash (symbol-function s) *builtins*) t))))
