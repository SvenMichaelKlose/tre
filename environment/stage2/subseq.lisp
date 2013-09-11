;;;;; tré – Copyright (c) 2007–2009,2011–2013 Sven Michael Klose <pixel@copei.de>

(functional subseq)

(defun list-subseq (seq start end)
  (unless (integer== start end)
    (labels ((copy (lst len)
               (& lst (integer< 0 len)
                  (cons (car lst)
				        (copy (cdr lst) (integer-- len))))))
      (when seq
        (& (integer> start end)
           (xchg start end))
        (copy (nthcdr start seq) (integer- end start))))))

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
