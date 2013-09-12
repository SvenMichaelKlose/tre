;;;;; tré – Copyright (c) 2009–2010,2012 Sven Michael Klose <pixel@copei.de>

(defun starts-with? (x head &key (ignore-case? nil))
  (unless (< (length x) (length head))
    (let s (force-string x)
      (string== (optional-string-downcase head :convert? ignore-case?)
			    (optional-string-downcase (subseq s 0 (length head)) :convert? ignore-case?)))))
