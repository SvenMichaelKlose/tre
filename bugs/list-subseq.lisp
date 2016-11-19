; In the PHP target #'COPY-NUM loses the first argument to the
; returned cons in pass EXPRESSION-EXPAND. It's very likely that
; this is related to introducing lexical scope and exporting closures.
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
