;;;;; nix operating system project
;;;;; Copyright (c) 2007 Sven Klose <pixel@copei.de>

(defun subseq (seq start &optional (end 99999))
  (labels ((copy (lst len)
             (when lst
               (when (< 0 len)
                 (cons (car lst) (copy (cdr lst) (1- len)))))))
  (when seq
    (when (> start end)
      (xchg start end))
    (if (consp seq)
        (copy (nthcdr start seq) (- end start))
        (%error "only cons supported yet")))))

(define-test "SUBSEQ basically works"
  ((subseq '(1 2 3 4) 1 3))
  '(2 3))

(define-test "SUBSEQ works without end"
  ((subseq '(1 2 3 4) 2))
  '(3 4))
