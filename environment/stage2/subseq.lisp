;;;;; TRE environment
;;;;; Copyright (c) 2007-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Subsequences

(defun subseq-list (seq start end)
  (labels ((copy (lst len)
             (when (and lst (< 0 len))
               (cons (car lst)
					 (copy (cdr lst) (1- len))))))
    (when seq
      (when (> start end)
        (xchg start end))
      (copy (nthcdr start seq) (- end start)))))

(defun %subseq-sequence (maker seq start end)
  (when (> start end)
    (xchg start end))
  (with (seqlen  (length seq))
  	(when (< start seqlen)
	  (when (>= end seqlen)
	    (setf end seqlen))
  	  (with (l (- end start)
		     s (funcall maker l))
        (dotimes (x l s)
	  	  (setf (elt s x) (elt seq (+ start x))))))))

;; XXX unify with SUBSEQ-SEQUENCE
(defun %subseq-string (seq start end)
  (unless (= start end)
    (when (> start end)
      (xchg start end))
    (with (seqlen  (length seq))
  	  (when (< start seqlen)
	    (when (>= end seqlen)
	      (setf end seqlen))
  	    (with (l (- end start)
		       s (make-string 0))
          (dotimes (x l s)
	  	    (setf s (+ s (string (elt seq (+ start x)))))))))))

(defun subseq (seq start &optional (end 99999))
  (when seq
	(if
	  (consp seq)
		(subseq-list seq start end)
	  (stringp seq)
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

(define-test "SUBSEQ returns NIL when start and end are the same"
  ((subseq "lisp" 1 1))
  nil)
