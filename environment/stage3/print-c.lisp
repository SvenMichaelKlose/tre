;;;;; trè – Copyright (c) 2012,2014 Sven Michael Klose <pixel@copei.de>

(defun %print-object (x str info))

(defun %print-get-args (args def)
  (catch nil
    (argument-expand 'print def args)))
