;;;;; TRE environment
;;;;; Copyright (c) 2007 Sven Klose <pixel@copei.de>

(defun group (l size)
  (when l
    (cons (subseq l 0 size) (group (subseq l size) size))))
