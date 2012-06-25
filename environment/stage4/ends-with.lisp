;;;;; tré – Copyright (c) 2009,2012 Sven Michael Klose <pixel@copei.de>

(defun ends-with? (x tail &key (ignore-case? nil))
  (unless (< (length x) (length tail))
    (let s (force-string x)
      (string== (optional-string-downcase tail :convert? ignore-case?)
    		    (optional-string-downcase (subseq s (- (length s) (length tail))) :convert? ignore-case?)))))
