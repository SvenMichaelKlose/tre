;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defun aadjoin (key value lst &key (test #'eql) (to-end? nil))
  (? (assoc key lst :test test)
     (aprog1 (assoc key (copy-alist lst) :test test)
       (= .! value))
     (? to-end?
        (+ lst (list (. key value)))
        (. (. key value) lst))))

(defmacro aadjoin! (key value lst &key (test #'eql) (to-end? nil))
  `(= ,lst (aadjoin ,key ,value ,lst :test ,test :to-end? ,to-end?)))
