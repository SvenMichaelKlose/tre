;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defun aadjoin (key value lst &key (test #'eql) (to-end? nil))
  (!? (assoc-value key lst :test test)
      (return !))
  (? to-end?
     (+ lst (list (. key value)))
     (. (. key value) lst)))

(defmacro aadjoin! (key value lst &key (test #'eql) (to-end? nil))
  `(= ,lst (aadjoin ,key ,value ,lst :test ,test :to-end? ,to-end?)))
