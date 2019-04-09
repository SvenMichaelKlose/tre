(functional subseq)

(fn list-subseq (seq start &optional (end 999999))
  (when (& seq
           (not (== start end)))
    (& (> start end)
       (xchg start end))
    (with-queue q
      (with (len (- end start)
             lst (nthcdr start seq))
        (while (& lst
                  (< 0 len))
               (queue-list q)
          (enqueue q lst.)
          (--! len)
          (= lst .lst))))))

(fn %subseq-sequence (maker seq start end)
  (unless (== start end)
    (!= (length seq)
      (when (< start !)
        (& (>= end !)
           (= end !))
        (with (l  (- end start)
               s  (funcall maker l))
          (dotimes (x l s)
            (= (elt s x) (elt seq (+ start x)))))))))

(fn subseq (seq start &optional (end 99999))
  (when seq
    (& (> start end)
       (xchg start end))
    (pcase seq
      list?    (list-subseq seq start end)
      string?  (string-subseq seq start end)
      array?   (%subseq-sequence #'make-array seq start end)
      (error "Type of ~A not supported." seq))))
