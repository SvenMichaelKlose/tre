;;;;; tré – Copyright (c) 2009–2010,2012–2014 Sven Michael Klose <pixel@copei.de>

(defun head? (x head &key (ignore-case? nil))
  (alet (length head)
    (unless (< (length x) !)
      (string== (optional-string-downcase head :convert? ignore-case?)
                (optional-string-downcase (subseq (string x) 0 !) :convert? ignore-case?)))))
