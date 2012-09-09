;;;;; tré – Copyright (c) 2005–2006,2008,2010–2012 Sven Michael Klose <pixel@copei.de>

(? (not (eq t *BUILTIN-MEMBER*))
   (defun member (elm lst &key (test #'eql))
     (? lst
        (? (funcall test elm (car lst))
           lst
           (member elm (cdr lst) :test test)))))

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

(defun %member-if-r (pred lst)
  (? lst
     (? (funcall pred (car lst))
	    lst
        (%member-if-r pred (cdr lst)))))

(defun member-if (pred &rest lsts)
  (| (%member-if-r pred (car lsts))
     (? (cdr lsts)
        (apply #'member-if pred (cdr lsts)))))
