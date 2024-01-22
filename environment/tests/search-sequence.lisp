(deftest "FIND finds elements"
  ((find 's '(l i s p)))
  's)

(deftest "FIND accepts :FROM-END"
  ((find 's '(l i s p) :from-end t))
  's)

(deftest "FIND accepts :END"
  ((find 's '(l i s p) :end 1))
  nil)

(deftest "FIND accepts :START"
  ((find 'l '(l i s p) :start 1))
  nil)

(deftest "FIND accepts :START, :END, :FROM-END"
  ((find 'l '(l i s p) :start 1 :end 2 :from-end 1))
  nil)

(deftest "FIND-IF finds elements"
  ((find-if #'number? '(l i 5 p)))
  5)

(deftest "POSITION works with character list"
  ((position 's '(l i s p)))
  2)

(deftest "POSITION works with strings"
  ((position #\/ "lisp/foo/bar"))
  4)

(deftest "SOME works"
  ((& (some #'number? '(a b 3)))
      (notany #'number? '(a b c)))
  t)

(deftest "EVERY works"
  ((& (every #'number? '(1 2 3))
      (not (every #'number? '(1 2 a)))))
  t)
