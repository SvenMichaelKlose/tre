;;;;; tré – Copyright (c) 2008–2010,2012–2014 Sven Michael Klose <pixel@copei.de>

(defun trim-tail (seq tail &key (test #'equal))
  (alet (length seq)
	(when (< 0 !)
      (? (tail? seq tail :test test)
	     (trim-tail (subseq seq 0 (- ! (length tail))) tail :test test)
		 seq))))

(defun trim-head (seq head &key (test #'equal))
  (when (< 0 (length seq))
    (? (head? seq head :test test)
       (trim-head (subseq seq (length head)) head :test test)
       seq)))

(defun trim (seq obj &key (test #'equal))
  (& seq
     (? (< 0 (length seq))
  	    (trim-tail (trim-head seq obj :test test) obj :test test)
	    seq)))

(define-test "TRIM-HEAD works"
  ((trim-head "  " " "))
  nil)

(define-test "TRIM-TAIL works"
  ((trim-tail "  " " "))
  nil)

(define-test "TRIM works"
  ((trim "  " " "))
  nil)
