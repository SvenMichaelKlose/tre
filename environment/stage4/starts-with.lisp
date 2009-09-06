;;;;; TRE environment
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun starts-with (x head)
  (let s (force-string x)
    (string= head (subseq s 0 (length head)))))
