; tré – Copyright (c) 2005–2006,2008,2010–2015 Sven Michael Klose <pixel@copei.de>

(functional member)

(defun member (elm lst &key (test #'eql))
  (do ((i lst .i))
      ((not i))
    (? (funcall test elm i.)
       (return-from member i))))

(defun member-if (pred &rest lsts)
  (@ (i lsts)
    (do ((j i .j))
        ((not j))
      (? (funcall pred j.)
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
