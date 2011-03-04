;;;;; TRE environment
;;;;; Copyright (c) 2011 Sven Klose <pixel@copei.de>

(defun without-head (x head)
  (? (starts-with? x head)
     (subseq x (length head))
     x))
