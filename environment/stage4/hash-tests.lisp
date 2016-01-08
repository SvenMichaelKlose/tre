; tré – Copyright (c) 2005–2006,2008–2015 Sven Michael Klose <pixel@copei.de>

(define-test "HASHKEYS symbols"
  ((let h (make-hash-table :test #'eq)
     (= (href h 'a) 'x)
     (= (href h 'b) 'x)
     (= (href h 'c) 'x)
     (sort (hashkeys h) :test #'((a b) (string<= (symbol-name a) (symbol-name b))))))
  '(a b c))
