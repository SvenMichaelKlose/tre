;;;; TRE compiler
;;;; Copyright (C) 2005-2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Miscellaneous utilities.

(defun print-symbols (forms)
  (dolist (i forms)
    (verbose " ~A" (symbol-name i))))
