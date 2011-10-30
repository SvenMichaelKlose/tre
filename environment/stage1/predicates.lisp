;;;;; tré - Copyright (c) 2005-2006,2008-2009,2011 Sven Klose <pixel@copei.de>

(functional atom cons? symbol? number? string? function? array? zerop evenp endp symbol? keyword? integerp)

(defun zerop (x)
  (eq x 0))

(defun evenp (x)
  (= 0 (mod x 2)))

(defun endp (x)
  (eq x nil))

(defun variablep (x)
  (and (atom x)
	   (not (or (string? x)
				(number? x)))))

(defun keyword? (x)
  (and (symbol? x)
	   (eq (symbol-package x)
		   *keyword-package*)))

(defun integerp (x)
  (and (number? x)
	   (not (character? x))))

(define-test "NOT works with NIL"
  ((not nil))
  t)

(define-test "NOT works with T"
  ((not t))
  nil)

(define-test "KEYWORDP recognizes keyword-packaged symbols"
  ((keyword? :lisp))
  t)

(define-test "KEYWORDP works with standard symbols"
  ((keyword? 'lisp))
  nil)
