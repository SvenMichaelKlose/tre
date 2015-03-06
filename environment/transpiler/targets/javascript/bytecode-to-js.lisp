; tré – Copyright (c) 2013,2015 Sven Michael Klose <pixel@copei.de>

(defun bytecode-to-js (x)
  (@ [`(= ,_. #'(,._.
                 (trecode-call ,_. ,(compiled-list (argument-expand-names _. ._.))))
          (slot-value ,_. '_tre-bytecode) (list-array ,(compiled-tree _ :quoted? t)))]
          x))
