;;;;; tré – Copyright (c) 2007–2009,2011–2012 Sven Michael Klose <pixel@copei.de>

(defun string-subseq (seq start &optional (end 99999))
  (? (integer== start end)
	 ""
     (with (seqlen  (length seq))
       (when (integer< start seqlen)
         (when (integer>= end seqlen)
	       (= end seqlen))
  	     (with (l (integer- end start)
	            s (make-string 0))
           (dotimes (x l s)
	  	     (= s (+ s (string (elt seq (integer+ start x)))))))))))
