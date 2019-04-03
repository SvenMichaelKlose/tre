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
                   (unless (equal result expected)
                     (%princ " FAILED")
                     (%princ " Expected:")
                     (%princ expected)
                     (%princ " Result:")
                     (%princ result)))
                     (%princ "<br>
")))]
           *tests*)
      (fn environment-tests ()
        ,@(@ #'list (reverse names))
        (%princ "Tests done.")))))
