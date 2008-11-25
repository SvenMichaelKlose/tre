;;;; TRE environment
;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

(defun trim (obj seq &key (test #'eql))
  "Trim start and end of sequence where element is equal to 'obj'."
  (when seq
    (if (funcall test obj (elt seq 0))
		(trim obj (subseq seq 1) :test test)
		(with (len (length seq))
          (if (funcall test obj (elt seq (1- len)))
		      (trim obj (subseq seq 0 (1- len)) :test test)
			  seq)))))

; XXX tests missing
;(print (trim " " "  malcolm in the middle  " :test #'string=))
