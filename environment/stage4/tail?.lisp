;;;;; tré – Copyright (c) 2009,2012,2014 Sven Michael Klose <pixel@copei.de>

(defun tail? (x tail &key (ignore-case? nil))
  (alet (length tail)
    (unless (< (length x) !)
      (let s (string x)
        (string== (optional-string-downcase tail :convert? ignore-case?)
    		      (optional-string-downcase (subseq s (- (length s) !)) :convert? ignore-case?))))))
