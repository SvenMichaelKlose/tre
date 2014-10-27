;;;;; tré – Copyright (c) 2005,2008-2009,2012 Sven Michael Klose <pixel@copei.de>

(define-test "CHARACTER- literal"
  ((== 1 (character- #\b #\a)))
  t)

(define-test "CHARACTER+ literal"
  ((== 66 (character+ #\A (code-char 1))))
  t)

(define-test "INTEGER- literal"
  ((== 1 (character- 66 65)))
  t)

(define-test "INTEGER+ literal"
  ((== 66 (integer+ 65 1)))
  t)

(define-test "+ INTEGER and CHARACTER"
  ((== 66 (+ 65 (code-char 1))))
  t)

(define-test "== empty string"
  ((let s ""
	 (== "" s)))
  t)
