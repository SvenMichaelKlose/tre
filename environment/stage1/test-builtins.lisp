;;;;; tré – Copyright (C) 2006,2009,2011–2014 Sven Michael Klose <pixel@copei.de>

(define-test "CAR accepts NIL"
  ((car nil))
  nil)

(define-test "CDR accepts NIL"
  ((car nil))
  nil)

(define-test "RPLACA returns cons"
  ((rplaca (cons nil nil) 42))
  (cons 42 nil))

(define-test "RPLACD returns cons"
  ((rplacd (cons nil nil) 42))
  (cons nil 42))

(define-test "ATOM recognizes atoms"
  ((atom nil))
  t)

(define-test "ATOM fails on conses"
  ((atom (cons 23 42)))
  nil)

(define-test "CONS?"
  ((cons? (cons 1 1)))
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

(define-test "NUMBER? recognizes characters"
  ((number? #\a))
  t)

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
  ((function? #'%backquote))
  t)

(define-test "FUNCTION? recognizes built-in functions"
  ((function? #'car))
  t)

;(define-test "FUNCTION? doesn't recognize built-in special forms"
;  ((function? #'block))
;  nil)

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

(define-test "LAST return NIL for empty list"
  ((last nil))
  nil)

(define-test "== works with floats"
  ((== 1 1))
  t)

(define-test "== works with characters"
  ((== #\A #\A))
  t)

(define-test "if 0 is a boolean 'true'"
  ((? 0 t))
  t)

(define-test "ELT returns CHARACTER of STRING"
  ((character? (elt "fnord" 0)))
  t)

(define-test "NTHCDR works at start"
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

; + - * / MOD
; LOGXOR
; MAKE-SYMBOL ATOM SYMBOL-VALUE %TYPE-ID
; SYMBOL-FUNCTION SYMBOL-PACKAGE
; BOUNDP FBOUNDP
; MACRO? STRING?
; == < >
; BIT-OR BIT-AND
; << >>
