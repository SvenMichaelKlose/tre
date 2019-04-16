(functional head?)
(fn head? (x head &key (test #'equal))
  (funcall test head (subseq x 0 (length head))))

(fn without-head (x head)
  (? (head? x head)
     (subseq x (length head))
     x))
