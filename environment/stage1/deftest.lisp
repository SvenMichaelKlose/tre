(var *tests* nil)

(%fn test-equal (x y)
  (?
    (atom x)    (eql x y)
    (atom y)    (eql x y)
    (test-equal x. y.)
                (test-equal .x .y)))

(%fn do-test (test)
  (? *print-definitions?*
     (print test.))
  (? (not (test-equal (eval (macroexpand .test.))
                      (eval (macroexpand ..test.))))
     (progn
       (print test.)
       (print 'FAILED-RESULT)
       (print (eval (macroexpand .test.)))
       (print 'WANTED-RESULT)
       (print (eval (macroexpand ..test.)))
       (invoke-debugger))))

(%fn do-tests (&optional (tests *tests*))
  (? (not tests)
     nil
     (progn
       (do-test tests.)
       (do-tests .tests))))

;; Add test to global list.
(defmacro deftest (description expr result)
  (print-definition (list 'deftest description))
  (setq *tests* (. (. description
                      (. (. 'block (. nil expr))
                         (. result nil)))
                   *tests*))
  (do-test *tests*.)
  nil)
