(fn aadjoin (key value lst &key (test #'eql) (to-end? nil))
  (? (assoc key lst :test test)
     (aprog1 (copy-alist lst)
       (= (cdr (assoc key ! :test test)) value))
     (? to-end?
        (+ lst (list (. key value)))
        (. (. key value) lst))))

(defmacro aadjoin! (key value lst &key (test #'eql) (to-end? nil))
  `(= ,lst (aadjoin ,key ,value ,lst :test ,test :to-end? ,to-end?)))
