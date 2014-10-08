;;;;; tré – Copyright (c) 2005–2006,2008,2010–2014 Sven Michael Klose <pixel@copei.de>

(functional member)

(defun member (elm lst &key (test #'eql))
  (do ((i lst (cdr i)))
      ((not i))
    (? (funcall test elm (car i))
       (return-from member i))))

(defun member-if (pred &rest lsts)
  (dolist (i lsts)
    (do ((j i (cdr j)))
        ((not j))
      (? (funcall pred (car j))
         (return-from member-if j)))))

(defun member-if-not (pred &rest lsts)
  (member-if #'((_) (not (funcall pred _))) lsts))

(define-test "MEMBER finds elements"
  ((? (member 's '(l i s p))
	  t))
  t)

(define-test "MEMBER finds elements with user predicate"
  ((? (member "lisp" '("tre" "lisp") :test #'string==)
	  t))
  t)

(define-test "MEMBER falsely detects foureign elements"
  ((member 'A '(l i s p)))
  nil)
