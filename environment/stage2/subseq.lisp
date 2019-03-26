; tré – Copyright (c) 2007–2009,2011–2015 Sven Michael Klose <pixel@copei.de>

(functional subseq)

(defun list-subseq (seq start &optional (end 999999))
  (when (& seq
           (not (== start end)))
    (& (> start end)
       (xchg start end))
    (with (copy-num #'((lst len)
                        (& lst
                            (< 0 len)
                            (. lst.
                               (copy-num .lst (-- len))))))
      (copy-num (nthcdr start seq) (- end start)))))

(defun %subseq-sequence (maker seq start end)
  (unless (== start end)
    (alet (length seq)
      (when (< start !)
	    (& (>= end !)
	       (= end !))
  	    (with (l  (- end start)
	           s  (funcall maker l))
          (dotimes (x l s)
	        (= (elt s x) (elt seq (+ start x)))))))))

(defun subseq (seq start &optional (end 99999))
  (when seq
    (& (> start end)
       (xchg start end))
	(pcase seq
	  cons?    (list-subseq seq start end)
	  string?  (string-subseq seq start end)
	  array?   (%subseq-sequence #'make-array seq start end)
      (error "Type of ~A not supported." seq))))
