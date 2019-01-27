(fn lexical2 ()
  (labels ((x () 2))
    (unless (== 2 (x))
      (print (x))
      (%error "LEXICAL2: X not 2."))
    (x)))

(fn lexical-test ()
  (labels ((x (cnt)
                cnt
	            (unless (== 2 (lexical2))
                  (print (lexical2))
                  (%error "LEXICAL-TEST: Parent (X) called."))
                1))
    (unless (== 1 (x 42))
      (print (x 42))
      (%error "LEXICAL-TEST: (X 42) is not 1."))))

(lexical-test)
