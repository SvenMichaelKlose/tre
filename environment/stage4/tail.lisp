(functional tail?)
(fn tail? (x tail &key (test #'equal))
  (with (xlen  (length x)
         tlen  (length tail))
    (unless (< xlen tlen)
      (funcall test tail (subseq x (- xlen tlen))))))

(fn without-tail (x tail)
  (? (tail? x tail)
     (subseq x 0 (- (length x) (length tail)))
     x))
