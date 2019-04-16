(deftest "NOT returns NIL for empty string"
  ((not ""))
  nil)

(deftest "Empty string is not NIL"
  ((eq nil ""))
  nil)

(deftest "KEYWORD? recognizes keywords"
  ((keyword? :a))
  t)

(deftest "KEYWORD? returns NIL for non-keywords"
  ((keyword? 'a))
  nil)

(deftest "CAR accepts NIL"
  ((car nil))
  nil)

(deftest "CDR accepts NIL"
  ((car nil))
  nil)

(deftest "RPLACA returns cons"
  ((rplaca (. nil nil) 42))
  (. 42 nil))

(deftest "RPLACD returns cons"
  ((rplacd (. nil nil) 42))
  (. nil 42))

(deftest "ATOM recognizes atoms"
  ((atom nil))
  t)

(deftest "ATOM fails on conses"
  ((atom (. 23 42)))
  nil)

(deftest "CONS?"
  ((cons? (. 1 1)))
  t)

(deftest "CONS? fails on atoms"
  ((cons? 'a))
  nil)

(deftest "CONS? fails on numbers"
  ((cons? 1))
  nil)

(deftest "CONS? fails on characters"
  ((cons? #\1))
  nil)

(deftest "CONS? fails on strings"
  ((cons? "1"))
  nil)

(deftest "CONS? fails on arrays"
  ((cons? (make-array 1)))
  nil)

(deftest "SYMBOL?"
  ((symbol? 'a))
  t)

(deftest "SYMBOL? fails on cells"
  ((symbol? (list 'a)))
  nil)

(deftest "SYMBOL? fails on numbers"
  ((symbol? 1))
  nil)

(deftest "SYMBOL? fails on characters"
  ((symbol? #\1))
  nil)

(deftest "SYMBOL? fails on strings"
  ((symbol? "1"))
  nil)

(deftest "SYMBOL? fails on arrays"
  ((symbol? (make-array 1)))
  nil)

(deftest "NUMBER? recognizes numbers"
  ((number? 42))
  t)

(deftest "NUMBER? fails on characters"
  ((number? #\a))
  nil)

(deftest "NUMBER? fails on arrays"
  ((number? (make-array 1)))
  nil)

(deftest "NUMBER? fails on symbols"
  ((number? 'a))
  nil)

(deftest "CHARACTER? recognizes characters"
  ((character? #\a))
  t)

(deftest "CHARACTER? fails on symbols"
  ((character? 'a))
  nil)

(deftest "CHARACTER? fails on cells"
  ((character? (list 1)))
  nil)

(deftest "CHARACTER? fails on numbers"
  ((character? 1))
  nil)

(deftest "CHARACTER? fails on arrays"
  ((character? (make-array 1)))
  nil)

(deftest "CHARACTER? fails on strings"
  ((character? "1"))
  nil)

(deftest "EQL wants same type of numbers"
  ((eql 65 #\A))
  nil)

(deftest "FUNCTION? recognizes functions"
  ((function? #'copy-list))
  t)

(deftest "FUNCTION? recognizes built-in functions"
  ((function? #'car))
  t)

(deftest "STRING? recognizes strings"
  ((string? "some string"))
  t)

(deftest "STRING? fails on numbers"
  ((string? 1))
  nil)

(deftest "STRING? fails on symbols"
  ((string? 'a))
  nil)

(deftest "CODE-CHAR converts number to char"
  ((code-char 65))
  #\A)

(deftest "CHAR-CODE converts char to number"
  ((code-char 65))
  #\A)

(deftest "SETQ returns the last value set"
  ((#'((a b c)
     (setq a 23 b 5 c 42)) nil nil nil))
  42)

(deftest "IDENTITY"
  ((identity t))
  t)

(deftest "LAST works"
  ((last '(1 2 3)))
  '(3))

(deftest "LAST returns NIL for empty list"
  ((last nil))
  nil)

(deftest "== works with floats"
  ((== 1 1))
  t)

(deftest "0 is a boolean T"
  ((? 0 t))
  t)

(deftest "NTHCDR works at the start"
  ((nthcdr 0 '(a b c)))
  '(a b c))

(deftest "NTHCDR works in the middle"
  ((nthcdr 1 '(a b c)))
  '(b c))

(deftest "NTHCDR works at the end"
  ((nthcdr 2 '(a b c)))
  '(c))

(deftest "NTHCDR works beyond the end"
  ((nthcdr 3 '(a b c)))
  nil)
