; tré – Copyright (c) 2007–2009,2011–2014 Sven Michael Klose <pixel@copei.de>

(functional subseq)

(defun copy-num (lst len)
  (& lst
     (integer< 0 len)
     (. lst. (copy-num .lst (integer-- len)))))

(defun list-subseq (seq start &optional (end 999999))
  (when (& seq
           (not (integer== start end)))
    (& (integer> start end)
       (xchg start end))
    (copy-num (nthcdr start seq) (integer- end start))))

(defun %subseq-sequence (maker seq start end)
  (unless (integer== start end)
    (alet (length seq)
      (when (integer< start !)
	    (& (integer>= end !)
	       (= end !))
  	    (with (l (integer- end start)
	           s (funcall maker l))
          (dotimes (x l s)
	        (= (elt s x) (elt seq (integer+ start x)))))))))

(defun subseq (seq start &optional (end 99999))
  (when seq
    (& (integer> start end)
       (xchg start end))
	(?
	  (cons? seq)   (list-subseq seq start end)
	  (string? seq) (string-subseq seq start end)
	  (array? seq)  (%subseq-sequence #'make-array seq start end)
      (error "Type of ~A not supported." seq))))
