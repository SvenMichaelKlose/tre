;;;;; tré – Copyright (c) 2005–2006,2008,2010–2012 Sven Michael Klose <pixel@copei.de>

(? (not (eq t *BUILTIN-MEMBER*))
   (progn
     (defun %member-r (elm lst)
       (? lst
          (? (equal elm (car lst))
			 lst
             (%member-r elm (cdr lst)))))
     (defun member (elm &rest lsts)
       (| (%member-r elm (car lsts))
          (? (cdr lsts)
             (apply #'member elm (cdr lsts)))))))

(define-test "MEMBER finds elements"
  ((? (member 's '(i) '(l i k e) '(l i s p))
	  t))
  t)

(define-test "MEMBER finds elements with user predicate"
  ((? (member "lisp" '("tre" "lisp") :test #'string==)
	  t))
  t)

(define-test "MEMBER detects foureign elements"
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
