;;;;; TRE environment
;;;;; Copyright (c) 2007-2009,2011 Sven Klose <pixel@copei.de>

(defun subseq-list (seq start end)
  (unless (integer= start end)
    (labels ((copy (lst len)
               (when (and lst (integer< 0 len))
                 (cons (car lst)
					   (copy (cdr lst) (integer-1- len))))))
      (when seq
        (when (integer> start end)
          (xchg start end))
        (copy (nthcdr start seq) (integer- end start))))))

(defun %subseq-sequence (maker seq start end)
  (unless (integer= start end)
    (with (seqlen  (length seq))
  	  (when (integer< start seqlen)
	    (when (integer>= end seqlen)
	      (setf end seqlen))
  	    (with (l (integer- end start)
		       s (funcall maker l))
          (dotimes (x l s)
	  	    (setf (elt s x) (elt seq (integer+ start x)))))))))

;; XXX unify with SUBSEQ-SEQUENCE
(defun %subseq-string (seq start end)
  (? (integer= start end)
	 ""
     (with (seqlen  (length seq))
       (when (integer< start seqlen) ; XXX return NIl when out of range for JavaScript.
         (when (integer>= end seqlen)
	       (setf end seqlen))
  	     (with (l (integer- end start)
	            s (make-string 0))
           (dotimes (x l s)
	  	     (setf s (+ s (string (elt seq (integer+ start x)))))))))))

(defun subseq (seq start &optional (end 99999))
  (when seq
    (when (integer> start end)
      (xchg start end))
	(?
	  (consp seq)
		(subseq-list seq start end)
	  (string? seq)
		(%subseq-string seq start end)
	  (arrayp seq)
		(%subseq-sequence #'make-array seq start end)
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
  ((string= "" (subseq "lisp" 1 1)))
  t)
