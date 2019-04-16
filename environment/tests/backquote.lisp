(deftest "BACKQUOTE"
  (`(1 2 3))
  `(1 2 3))

(deftest "QUASIQUOTE"
  (`(1 ,2 ,,3 ,,4))
  '(1 2 ,3 ,4))

(deftest "QUASIQUOTE-SPLICE"
  (`(1 ,@'(2) ,,@3 ,,@4))
  '(1 2 ,@3 ,@4))
