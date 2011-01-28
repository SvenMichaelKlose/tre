;;;;; TRE environment
;;;;; Copyright (C) 2006,2009,2011 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Early built-in function tests

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

(define-test "CONSP"
  ((cons? (cons 1 1)))
  t)

(define-test "CONSP fails on atoms"
  ((cons? 'a))
  nil)

(define-test "CONSP fails on numbers"
  ((cons? 1))
  nil)

(define-test "CONSP fails on characters"
  ((cons? #\1))
  nil)

(define-test "CONSP fails on strings"
  ((cons? "1"))
  nil)

(define-test "CONSP fails on arrays"
  ((cons? (make-array 1)))
  nil)

(define-test "SYMBOLP"
  ((symbol? 'a))
  t)

(define-test "SYMBOLP fails on cells"
  ((symbol? (list 'a)))
  nil)

(define-test "SYMBOLP fails on numbers"
  ((symbol? 1))
  nil)

(define-test "SYMBOLP fails on characters"
  ((symbol? #\1))
  nil)

(define-test "SYMBOLP fails on strings"
  ((symbol? "1"))
  nil)

(define-test "SYMBOLP fails on arrays"
  ((symbol? (make-array 1)))
  nil)

(define-test "NUMBERP recognizes numbers"
  ((number? 42))
  t)

(define-test "NUMBERP recognizes characters"
  ((number? #\a))
  t)

(define-test "NUMBERP fails on arrays"
  ((number? (make-array 1)))
  nil)

(define-test "NUMBERP fails on symbols"
  ((number? 'a))
  nil)

(define-test "CHARACTERP recognizes characters"
  ((character? #\a))
  t)

(define-test "CHARACTERP fails on symbols"
  ((character? 'a))
  nil)

(define-test "CHARACTERP fails on cells"
  ((character? (list 1)))
  nil)

(define-test "CHARACTERP fails on numbers"
  ((character? 1))
  nil)

(define-test "CHARACTERP fails on arrays"
  ((character? (make-array 1)))
  nil)

(define-test "CHARACTERP fails on strings"
  ((character? "1"))
  nil)

(define-test "EQL wants same type of numbers"
  ((eql 65 #\A))
  nil)

(define-test "FUNCTIONP recognizes functions"
  ((function? #'%backquote))
  t)

(define-test "FUNCTIONP recognizes built-in functions"
  ((function? #'car))
  t)

;(define-test "FUNCTIONP doesn't recognize built-in special forms"
;  ((function? #'block))
;  nil)

(define-test "STRINGP recognizes strings"
  ((string? "some string"))
  t)

(define-test "STRINGP fails on numbers"
  ((string? 1))
  nil)

(define-test "STRINGP fails on symbols"
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

(define-test "= works with floats"
  ((= 1 1))
  t)

(define-test "= works with characters"
  ((= #\A #\A))
  t)

(define-test "if 0 is a boolean 'true'"
  ((if 0 t))
  t)

(define-test "ELT returns CHARACTER of STRING"
  ((character? (elt "fnord" 0)))
  t)

; + - * / MOD
; LOGXOR
; MAKE-SYMBOL ATOM SYMBOL-VALUE %TYPE-ID
; SYMBOL-FUNCTION SYMBOL-PACKAGE
; BOUNDP FBOUNDP
; MACROP STRINGP
; = < >
; BIT-OR BIT-AND
; << >>
