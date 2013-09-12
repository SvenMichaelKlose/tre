;;;; TRE environment
;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(defun pad (seq p)
  (when seq
    (cons seq.
    	  (when (< 1 (length seq))
			(cons p
				  (pad .seq p))))))
