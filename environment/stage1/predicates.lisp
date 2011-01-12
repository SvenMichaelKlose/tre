;;;;; TRE environment
;;;;; Copyright (c) 2005-2006,2008-2009,2011 Sven Klose <pixel@copei.de>

(defun zerop (x)
  (eq x 0))

(defun evenp (x)
  (= 0 (mod x 2)))

(defun endp (x)
  (eq x nil))

(defun symbolp (x)
  (and (atom x)
       (not (= 0 (length (symbol-name x))))))

(defun variablep (x)
  (and (atom x)
	   (not (or (stringp x)
				(numberp x)))))

(defun keywordp (x)
  (and (symbolp x)
	   (eq (symbol-package x)
		   *keyword-package*)))

(defun integerp (x)
  (and (numberp x)
	   (not (characterp x))))

(define-test "NOT works with NIL"
  ((not nil))
  t)

(define-test "NOT works with T"
  ((not t))
  nil)

(define-test "KEYWORDP recognizes keyword-packaged symbols"
  ((keywordp :lisp))
  t)

(define-test "KEYWORDP works with standard symbols"
  ((keywordp 'lisp))
  nil)
