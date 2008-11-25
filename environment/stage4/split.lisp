;;;; TRE environment
;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

(defun split (obj seq &key (test #'eql))
  "Split sequence where element is equal to 'obj' and excluding them."
  (when seq
    (with (pos (position obj seq :test test))
	  (if pos
		  (cons (subseq seq 0 pos)
			    (split obj (subseq seq (1+ pos)) :test test))
		  (list seq)))))

; XXX tests missing
;(print (split #\  "fnord bla"))
