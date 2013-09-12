;;;;; tré – Copyright (c) 2008–2010,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun trim-tail (obj seq &key (test #'eql))
  (alet (length seq)
	(when (< 0 !)
      (? (funcall test obj (elt seq (-- !)))
	     (trim-tail obj
			        (subseq seq 0 (-- !))
				    :test test)
		 seq))))

(defun trim-head (obj seq &key (test #'eql))
  (when (< 0 (length seq))
    (? (funcall test obj (elt seq 0))
	   (trim-head obj
			      (subseq seq 1)
			      :test test)
	   seq)))

(defun trim (obj seq &key (test #'eql))
  (& seq
     (? (< 0 (length seq))
  	    (trim-tail obj (trim-head obj seq :test test) :test test)
	    seq)))

(define-test "TRIM-HEAD works"
  ((trim-head #\  "  "))
  nil)

(define-test "TRIM-TAIL works"
  ((trim-tail #\  "  "))
  nil)

(define-test "TRIM works"
  ((trim #\  "  "))
  nil)
