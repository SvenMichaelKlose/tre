; trè – Copyright (c) 2012,2014–2015 Sven Michael Klose <pixel@copei.de>

(defun %print-object (x str info))

(defun %print-get-args (args def)
  (argument-expand 'print def args :concatenate-sublists? nil
                                   :break-on-errors? nil))
