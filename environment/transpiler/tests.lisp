(fn make-environment-tests ()
  (with (names  nil
         num    0)
    `(,@(@ [(++! num)
            (!= ($ 'test- num)
              (push ! names)
              `(fn ,! ()
                 (%princ ,(+ "Test " (string num) ", " _.))
                 (with (result    ,._.
                        expected  ,.._.)
                   (? (equal result expected)
                     (%princ "
")
                     (progn
                       (%princ " !!! FAILED !!! Expected: ")
                       (print expected)
                       (%princ " Result: ")
                       (print result))))))]
           *tests*)
      (fn environment-tests ()
        ,@(@ #'list (reverse names))
        (%princ "Tests done.")))))
