(functional find position)

(fn %find-if-list (pred seq from-end with-index)
  (alet (? from-end
           (reverse seq)
           seq)
    (? with-index
       (let idx 0
         (@ (i !)
           (& (funcall pred i idx)
              (return i))
           (++! idx)))
       (@ (i !)
         (& (funcall pred i)
            (return i))))))

(fn %find-if-sequence (pred seq start end from-end with-index)
  (& seq (< 0 (length seq))
     (let* ((e (| end (-- (length seq))))
            (s (| start 0)))
       (& (| (& (> s e) (not from-end))
             (& (< s e) from-end))
          (xchg s e))
       (do ((i s (? from-end
                    (-- i)
                    (++ i))))
           ((? from-end
               (< i e)
               (> i e)))
         (alet (elt seq i)
           (& (apply pred (. ! (& with-index (list i))))
              (return !)))))))
 
(fn find-if (pred seq &key (start nil) (end nil) (from-end nil) (with-index nil))
  (? (not (atom seq) start end)
     (%find-if-list pred seq from-end with-index)
     (%find-if-sequence pred seq start end from-end with-index)))

(fn find-if-not (pred seq &key (start nil) (end nil) (from-end nil) (with-index nil))
  (find-if [not (funcall pred _)] seq :start start :end end :from-end from-end :with-index with-index))

(fn find (obj seq &key (start nil) (end nil) (from-end nil) (test #'eql))
  (find-if [funcall test _ obj] seq :start start :end end :from-end from-end))

(fn position (obj seq &key (start nil) (end nil) (from-end nil) (test #'eql))
  (aprog1 nil
    (find-if #'((x i)
                 (& (funcall test x obj)
                    (= ! i)))
             seq :start start :end end :from-end from-end :with-index t)))

(fn position-if (pred seq &key (start nil) (end nil) (from-end nil))
  (aprog1 nil
    (find-if #'((x i)
                  (& (funcall pred x)
                     (= ! i)))
             seq :start start :end end :from-end from-end :with-index t)))

(fn some (pred &rest seqs)
  (find-if pred (apply #'append seqs)))

(fn every (pred &rest seqs)
  (@ (seq seqs t)
    (adotimes ((length seq))
      (| (funcall pred (elt seq !))
         (return-from every nil)))))

(fn none? (pred &rest args)
  (apply #'every [not (funcall pred _)] args))
