;;;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

(defun bytecode-to-js (x)
  (filter [`(= ,_. #'(,._.
                       (trecode-call ,_. ,(compiled-list (argument-expand-names _. ._.))))
               (slot-value ,_. '_tre-bytecode) (list-array ,(compiled-tree _ :quoted? t)))]
          x))
