;(define-test "HASHKEYS symbols" ; TODO: Make this work in the PHP back end.
;  ((let h (make-hash-table :test #'eq)
;     (= (href h 'a) 'x)
;     (= (href h 'b) 'x)
;     (= (href h 'c) 'x)
;     (sort (hashkeys h) :test #'((a b) (string<= (symbol-name a) (symbol-name b))))))
;  '(a b c))
