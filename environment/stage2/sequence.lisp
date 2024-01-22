(functional find position remove subseq list-subseq)

(fn %find-if-list (pred seq from-end with-index)
  (!= (? from-end
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
         (!= (elt seq i)
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
     (?
       (list? seq)
         (@ (i seq t)
           (| (funcall pred i)
              (return-from every nil)))
       (vector? seq)
         (adotimes ((length seq))
           (| (funcall pred (elt seq !))
              (return-from every nil)))
       (error "Not a sequence: ~A." seq))))

(fn notany (pred &rest args)
  (apply #'every [not (funcall pred _)] args))
(defmacro dosequence ((v seq &rest result) &body body)
  (with-gensym (evald-seq idx)
    `(let ,evald-seq ,seq
       (when ,evald-seq
         (dotimes (,idx (length ,evald-seq) ,@result)
           (let ,v (elt ,evald-seq ,idx)
             ,@body))))))

(defmacro adosequence (params &body body)
  (let p (? (atom params)
            (list params)
            params)
    `(dosequence (! ,p. ,.p.)
       ,@body)))

(fn remove-if (fun x)
  (? (array? x)
     (list-array (remove-if fun (array-list x)))
     (with-queue q
       (@ (i x (queue-list q))
         (| (funcall fun i)
            (enqueue q i))))))

(fn remove-if-not (fun x)
  (? (array? x)
     (list-array (remove-if-not fun (array-list x)))
     (with-queue q
       (@ (i x (queue-list q))
         (& (funcall fun i)
            (enqueue q i))))))

(fn remove (elm x &key (test #'eql))
  (remove-if [funcall test elm _] x))

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
