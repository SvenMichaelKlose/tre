;;;;; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(define-test "argument expansion works with simple list"
  ((equal (argument-expand 'test '(a b) '(2 3))
	      '((a . 2) (b . 3))))
  t)

(define-test "argument expansion works without :apply-values?"
  ((equal (argument-expand-names 'test '(a b))
	      '(a b)))
  t)

(define-test "argument expansion can handle nested lists"
  ((equal (argument-expand 'test '(a (b c) d) '(23 (2 3) 42))
	      '((a . 23) (b . 2) (c . 3) (d . 42))))
  t)

(define-test "argument expansion can handle nested lists without :apply-values?"
  ((equal (argument-expand-names 'test '(a (b c) d))
	      '(a b c d)))
  t)

(define-test "argument expansion can handle &REST"
  ((equal (argument-expand 'test '(a b &rest c) '(23 5 42 65))
		  '((a . 23) (b . 5) (c &rest 42 65))))
  t)

(define-test "argument expansion can handle &REST without :apply-values?"
  ((equal (argument-expand-names 'test '(a b c &rest d))
		  '(a b c d)))
  t)

(define-test "argument expansion can handle missing &REST"
  ((equal (argument-expand 'test '(a b &rest c) '(23 5))
		  '((a . 23) (b . 5) (c &rest))))
  t)

(define-test "argument expansion can handle missing &REST without :apply-values?"
  ((equal (argument-expand-names 'test '(a b &rest c))
		  '(a b c)))
  t)

(define-test "argument expansion can handle &OPTIONAL"
  ((equal (argument-expand 'test '(a b &optional c d)
                                 '(23 2 3 42))
		  '((a . 23) (b . 2) (c . 3) (d . 42))))
  t)

(define-test "argument expansion can handle &OPTIONAL without :apply-values?"
  ((equal (argument-expand-names 'test '(a b &optional c d))
		  '(a b c d)))
  t)

(define-test "argument expansion can handle &OPTIONAL with init forms"
  ((equal (argument-expand 'test '(a b &optional (c 3) (d 42))
                                 '(23 2))
		  '((a . 23) (b . 2) (c . 3) (d . 42))))
  t)

(define-test "argument expansion can handle &OPTIONAL with init forms without :apply-values?"
  ((equal (argument-expand-names 'test '(a b &optional (c 3) (d 42)))
		  '(a b c d)))
  t)

(define-test "argument expansion can handle &KEY"
  ((equal (argument-expand 'test '(a b &key c d)
                                 '(23 2 :c 3 :d 42))
		  '((a . 23) (b . 2) (c . 3) (d . 42))))
  t)

(define-test "argument expansion can handle &KEY with overloaded init forms"
  ((equal (argument-expand 'test '(a b &key (c 3) (d 42))
                                 '(23 2 :c 5 :d 65))
		  '((a . 23) (b . 2) (c . 5) (d . 65))))
  t)

(define-test "argument expansion can handle &KEY without :apply-values?"
  ((equal (argument-expand-names 'test '(a b &key c d))
		  '(a b c d)))
  t)

(define-test "argument expansion can handle &OPTIONAL and &KEY with init forms without :apply-values?"
  ((equal (argument-expand-names 'test '(a b &optional (c 3) &key (d 42)))
		  '(a b c d)))
  t)

(define-test "argument expansion can handle &OPTIONAL and &KEY with init forms with :apply-values?"
  ((equal (argument-expand 'test '(a b &optional (c 3) &key (d 42))
								 '(23 2 3 :d 65))
		  '((a . 23) (b . 2) (c . 3) (d . 65))))
  t)

;(define-test "argument expansion can handle &KEY with init forms"
;  ((equal (argument-expand '(a b &key (c 3) (d 42)) '(23 2) t)
;          '(values (a b c d) (23 2 3 42)))))
