(define-test "NOT returns NIL for empty string"
  ((not ""))
  nil)

(define-test "Empty string is not NIL"
  ((eq nil ""))
  nil)

(define-test "KEYWORD? recognizes keywords"
  ((keyword? :a))
  t)

(define-test "KEYWORD? returns NIL for non-keywords"
  ((keyword? 'a))
  nil)

(define-test "CAR accepts NIL"
  ((car nil))
  nil)

(define-test "CDR accepts NIL"
  ((car nil))
  nil)

(define-test "RPLACA returns cons"
  ((rplaca (. nil nil) 42))
  (. 42 nil))

(define-test "RPLACD returns cons"
  ((rplacd (. nil nil) 42))
  (. nil 42))

(define-test "ATOM recognizes atoms"
  ((atom nil))
  t)

(define-test "ATOM fails on conses"
  ((atom (. 23 42)))
  nil)

(define-test "CONS?"
  ((cons? (. 1 1)))
  t)

(define-test "CONS? fails on atoms"
  ((cons? 'a))
  nil)

(define-test "CONS? fails on numbers"
  ((cons? 1))
  nil)

(define-test "CONS? fails on characters"
  ((cons? #\1))
  nil)

(define-test "CONS? fails on strings"
  ((cons? "1"))
  nil)

(define-test "CONS? fails on arrays"
  ((cons? (make-array 1)))
  nil)

(define-test "SYMBOL?"
  ((symbol? 'a))
  t)

(define-test "SYMBOL? fails on cells"
  ((symbol? (list 'a)))
  nil)

(define-test "SYMBOL? fails on numbers"
  ((symbol? 1))
  nil)

(define-test "SYMBOL? fails on characters"
  ((symbol? #\1))
  nil)

(define-test "SYMBOL? fails on strings"
  ((symbol? "1"))
  nil)

(define-test "SYMBOL? fails on arrays"
  ((symbol? (make-array 1)))
  nil)

(define-test "NUMBER? recognizes numbers"
  ((number? 42))
  t)

(define-test "NUMBER? fails on characters"
  ((number? #\a))
  nil)

(define-test "NUMBER? fails on arrays"
  ((number? (make-array 1)))
  nil)

(define-test "NUMBER? fails on symbols"
  ((number? 'a))
  nil)

(define-test "CHARACTER? recognizes characters"
  ((character? #\a))
  t)

(define-test "CHARACTER? fails on symbols"
  ((character? 'a))
  nil)

(define-test "CHARACTER? fails on cells"
  ((character? (list 1)))
  nil)

(define-test "CHARACTER? fails on numbers"
  ((character? 1))
  nil)

(define-test "CHARACTER? fails on arrays"
  ((character? (make-array 1)))
  nil)

(define-test "CHARACTER? fails on strings"
  ((character? "1"))
  nil)

(define-test "EQL wants same type of numbers"
  ((eql 65 #\A))
  nil)

(define-test "FUNCTION? recognizes functions"
  ((function? #'copy-list))
  t)

(define-test "FUNCTION? recognizes built-in functions"
  ((function? #'car))
  t)

(define-test "STRING? recognizes strings"
  ((string? "some string"))
  t)

(define-test "STRING? fails on numbers"
  ((string? 1))
  nil)

(define-test "STRING? fails on symbols"
  ((string? 'a))
  nil)

(define-test "CODE-CHAR converts number to char"
  ((code-char 65))
  #\A)

(define-test "CHAR-CODE converts char to number"
  ((code-char 65))
  #\A)

(define-test "SETQ returns the last value set"
  ((#'((a b c)
	 (setq a 23 b 5 c 42)) nil nil nil))
  42)

(define-test "IDENTITY"
  ((identity t))
  t)

(define-test "LAST works"
  ((last '(1 2 3)))
  '(3))

(define-test "LAST returns NIL for empty list"
  ((last nil))
  nil)

(define-test "== works with floats"
  ((== 1 1))
  t)

(define-test "0 is a boolean T"
  ((? 0 t))
  t)

(define-test "ELT returns CHARACTER of STRING"
  ((character? (elt "fnord" 0)))
  t)

(define-test "NTHCDR works at the start"
  ((nthcdr 0 '(a b c)))
  '(a b c))

(define-test "NTHCDR works in the middle"
  ((nthcdr 1 '(a b c)))
  '(b c))

(define-test "NTHCDR works at the end"
  ((nthcdr 2 '(a b c)))
  '(c))

(define-test "NTHCDR works beyond the end"
  ((nthcdr 3 '(a b c)))
  nil)
