;;;;; tré – Copyright (c) 2007–2009,2011–2014 Sven Michael Klose <pixel@copei.de>

(functional subseq)

(defun copy-num (lst len)
  (& lst
     (integer< 0 len)
     (cons (car lst)
		   (copy-num (cdr lst) (integer-- len)))))

(define-test "COPY-NUM"
  ((copy-num '(a b c) 2))
  '(a b))

(defun list-subseq (seq start &optional (end 999999))
  (when (& seq
           (not (integer== start end)))
    (& (integer> start end)
       (xchg start end))
    (copy-num (nthcdr start seq) (integer- end start))))

#|
(define-test "LIST-SUBSEQ work at the beginning"
  ((list-subseq '(a b c) 0 1))
  '(a))

(define-test "LIST-SUBSEQ works in the middle"
  ((list-subseq '(1 2 3 4) 1 3))
  '(2 3))

(define-test "LIST-SUBSEQ works at the end"
  ((list-subseq '(1 2 3 4) 2))
  '(3 4))
|#

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

(define-test "SUBSEQ returns NIL when totally out of range"
  ((subseq "lisp" 10))
  nil)

(define-test "SUBSEQ returns empty string when start and end are the same"
  ((string== "" (subseq "lisp" 1 1)))
  t)
