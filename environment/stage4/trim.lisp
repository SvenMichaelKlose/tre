;;;; TRE environment
;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

(defun trim-tail (obj seq &key (test #'eql))
  (let len (length seq)
    (if (funcall test obj (elt seq (integer-1- len)))
	    (trim-tail obj
				   (subseq seq 0 (integer-1- len))
				   :test test)
		seq)))

(defun trim-head (obj seq &key (test #'eql))
  (if (funcall test obj (elt seq 0))
	  (trim-head obj
				 (subseq seq 1)
				 :test test)
	  seq))

(defun trim (obj seq &key (test #'eql))
  "Trim start and end of sequence where element is equal to 'obj'."
  (and seq
	   (if (integer< 0 (length seq))
  		   (trim-tail obj (trim-head obj seq :test test) :test test))
		   seq))

; XXX tests missing
