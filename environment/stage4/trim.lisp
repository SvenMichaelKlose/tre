(fn trim-tail (seq tail &key (test #'equal))
  (!= (length seq)
    (when (< 0 !)
      (? (tail? seq tail :test test)
         (trim-tail (subseq seq 0 (- ! (length tail))) tail :test test)
         seq))))

(fn trim-head (seq head &key (test #'equal))
  (when (< 0 (length seq))
    (? (head? seq head :test test)
       (trim-head (subseq seq (length head)) head :test test)
       seq)))

(functional trim)
(fn trim (seq obj &key (test #'equal))
  (& seq
     (? (< 0 (length seq))
        (trim-tail (trim-head seq obj :test test) obj :test test)
        seq)))
