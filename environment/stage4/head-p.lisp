(fn head? (x head &key (test #'equal))
  (funcall test head (subseq x 0 (length head))))
