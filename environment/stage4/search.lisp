;;;;; tré - Copyright (c) 2011 Sven Klose <pixel@copei.de>

(defun search (needle haystack &key (test #'eql))
  (and haystack
       (not (zero? (length haystack)))
       (or (and (funcall test needle (subseq haystack 0 (length needle)))
                haystack)
           (search needle (subseq haystack 1) :test test))))
