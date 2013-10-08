;;;;; tré – Copyright (c) 2009–2010,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun starts-with? (x head &key (ignore-case? nil))
  (unless (< (length x) (length head))
    (string== (optional-string-downcase head :convert? ignore-case?)
              (optional-string-downcase (subseq (ensure-string x) 0 (length head)) :convert? ignore-case?))))
