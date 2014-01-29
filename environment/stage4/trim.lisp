;;;;; tré – Copyright (c) 2008–2010,2012–2014 Sven Michael Klose <pixel@copei.de>

(defun trim-tail (obj seq &key (test #'equal))
  (with (lo   (length obj)
         ls   (length seq)
         pos  (- ls lo))
	(when (< 0 ls)
      (? (funcall test obj (subseq seq pos))
	     (trim-tail obj (subseq seq 0 pos) :test test)
		 seq))))

(defun trim-head (obj seq &key (test #'equal))
  (with (lo   (length obj)
         ls   (length seq))
    (when (< 0 ls)
      (? (funcall test obj (subseq seq 0 lo))
	     (trim-head obj (subseq seq lo) :test test)
	     seq))))

(defun trim (obj seq &key (test #'equal))
  (& seq
     (? (< 0 (length seq))
  	    (trim-tail obj (trim-head obj seq :test test) :test test)
	    seq)))

(define-test "TRIM-HEAD works"
  ((trim-head " " "  "))
  nil)

(define-test "TRIM-TAIL works"
  ((trim-tail " " "  "))
  nil)

(define-test "TRIM works"
  ((trim " " "  "))
  nil)
