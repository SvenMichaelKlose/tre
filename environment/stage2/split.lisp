(functional split)

(fn split-if (predicate seq &key (include? nil))
  (& seq
     (!? (position-if predicate seq)
         (. (subseq seq 0 (? include? (++ !) !))
            (split-if predicate (subseq seq (++ !)) :include? include?))
         (list seq))))

(fn split (obj seq &key (test #'eql) (include? nil))
  (& seq
     (!? (position obj seq :test test)
         (. (subseq seq 0 (? include? (++ !) !))
            (split obj (subseq seq (++ !)) :test test :include? include?))
         (list seq))))
