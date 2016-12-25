(defun split-if (predicate seq &key (include? nil))
  (& seq
     (!? (position-if predicate seq)
         (. (subseq seq 0 (? include?
                             (++ !)
                             !))
            (split-if predicate (subseq seq (++ !))
                      :include? include?))
         (list seq))))

(defun generic-split (obj seq &key (test #'eql) (include? nil))
  (& seq
     (!? (position obj seq :test test)
         (. (subseq seq 0 (? include?
                             (++ !)
                             !))
            (generic-split obj (subseq seq (++ !))
                           :test      test
                           :include?  include?))
         (list seq))))

(defun split (obj seq &key (test #'eql) (include? nil))
  (generic-split obj seq :test test :include? include?))
