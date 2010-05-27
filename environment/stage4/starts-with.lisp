;;;;; TRE environment
;;;;; Copyright (c) 2009-2010 Sven Klose <pixel@copei.de>

(defun starts-with? (x head &key (ignore-case? nil))
  (let s (force-string x)
    (string= (if ignore-case?
			     (string-downcase head)
				 head)
			 (let sub (subseq s 0 (length head))
			   (if ignore-case?
				   (string-downcase sub)
				   sub)))))
