;;;;; TRE environment
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun ends-with? (x tail &key (ignore-case? nil))
  (with (s (force-string x)
         x-tail (subseq s (integer- (length s)
						     		(length tail))))
    (string= (optional-string-downcase tail :convert? ignore-case?)
    		 (optional-string-downcase x-tail :convert? ignore-case?))))
