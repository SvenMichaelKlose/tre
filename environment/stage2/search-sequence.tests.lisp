(define-test "FIND finds elements"
  ((find 's '(l i s p)))
  's)

(define-test "FIND accepts :FROM-END"
  ((find 's '(l i s p) :from-end t))
  's)

(define-test "FIND accepts :END"
  ((find 's '(l i s p) :end 1))
  nil)

(define-test "FIND accepts :START"
  ((find 'l '(l i s p) :start 1))
  nil)

(define-test "FIND accepts :START, :END, :FROM-END"
  ((find 'l '(l i s p) :start 1 :end 2 :from-end 1))
  nil)

(define-test "FIND-IF finds elements"
  ((find-if #'number? '(l i 5 p)))
  5)

(define-test "POSITION works with character list"
  ((position 's '(l i s p)))
  2)

(define-test "POSITION works with strings"
  ((position #\/ "lisp/foo/bar"))
  4)

(define-test "SOME works"
  ((& (some #'number? '(a b 3)))
      (not (some #'number? '(a b c))))
  t)

(define-test "EVERY works"
  ((& (every #'number? '(1 2 3))
      (not (every #'number? '(1 2 a)))))
  t)
