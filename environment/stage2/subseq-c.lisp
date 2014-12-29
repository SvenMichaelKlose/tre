; tré – Copyright (c) 2007–2009,2011–2012,2014 Sven Michael Klose <pixel@copei.de>

(defun string-subseq (seq start &optional (end 99999))
  (? (== start end)
	 ""
     (with (seqlen  (length seq))
       (when (< start seqlen)
         (when (>= end seqlen)
	       (= end seqlen))
  	     (with (l  (- end start)
	            s  (make-string 0))
           (dotimes (x l s)
	  	     (= s (+ s (string (elt seq (+ start x)))))))))))
