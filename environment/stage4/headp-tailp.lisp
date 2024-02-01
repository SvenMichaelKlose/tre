(functional head?)

(fn head? (x head &key (test #'equal))
  (& (~> test head (subseq x 0 (length head)))
     x))

(fn without-head (x head)
  (? (head? x head)
     (subseq x (length head))
     x))
(functional tail?)

(fn tail? (x tail &key (test #'equal))
  (with (xlen  (length x)
         tlen  (length tail))
    (unless (< xlen tlen)
      (& (~> test tail (subseq x (- xlen tlen)))
         x))))

(fn without-tail (x tail)
  (? (tail? x tail)
     (subseq x 0 (- (length x) (length tail)))
     x))
