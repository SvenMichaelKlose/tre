;;;;; tré - Copyright (c) 2008-2012 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate length)

(defun length (x)
  (? x
     (? (cons? x)
	    (list-length x)
	    x.length)
     0))

(dont-obfuscate split)

(defun split (obj seq &key (test #'eql))
  (? (and (eq #'eql test)
          (string? seq))
     (array-list (seq.split (? (character? obj)
                               (char-string obj)
                               obj)))
     (generic-split obj seq)))
