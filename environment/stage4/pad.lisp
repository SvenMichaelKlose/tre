;;;; TRE environment
;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defun pad (seq p)
  (when seq
    (if (< 1 (length seq))
        (cons seq.
			  (cons p
					(pad .seq p)))
        (list seq.))))
