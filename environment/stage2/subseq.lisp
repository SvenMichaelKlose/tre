;;;;; tré – Copyright (c) 2007–2009,2011–2012 Sven Michael Klose <pixel@copei.de>

(functional subseq)

(defun subseq-list (seq start end)
  (unless (integer== start end)
    (labels ((copy (lst len)
               (when (and lst (integer< 0 len))
                 (cons (car lst)
					   (copy (cdr lst) (integer-1- len))))))
      (when seq
        (when (integer> start end)
          (xchg start end))
        (copy (nthcdr start seq) (integer- end start))))))

(defun %subseq-sequence (maker seq start end)
  (unless (integer== start end)
    (with (seqlen  (length seq))
  	  (when (integer< start seqlen)
	    (when (integer>= end seqlen)
	      (= end seqlen))
  	    (with (l (integer- end start)
		       s (funcall maker l))
          (dotimes (x l s)
	  	    (= (elt s x) (elt seq (integer+ start x)))))))))

(defun subseq (seq start &optional (end 99999))
  (when seq
    (when (integer> start end)
      (xchg start end))
	(?
	  (cons? seq) (subseq-list seq start end)
	  (string? seq) (%subseq-string seq start end)
	  (array? seq) (%subseq-sequence #'make-array seq start end)
	  (progn
		(print seq)
		(%error "type not supported")))))

(define-test "SUBSEQ basically works"
  ((subseq '(1 2 3 4) 1 3))
  '(2 3))

(define-test "SUBSEQ works without end"
  ((subseq '(1 2 3 4) 2))
  '(3 4))

(define-test "SUBSEQ returns NIL when totally out of range"
  ((subseq "lisp" 10))
  nil)

(define-test "SUBSEQ returns empty string when start and end are the same"
  ((string== "" (subseq "lisp" 1 1)))
  t)
