;;;;; TRE environment
;;;;; Copyright (C) 2005-2006,2008,2010 Sven Klose <pixel@copei.de>

(if (not (eq t *BUILTIN-MEMBER*))
  (progn
    (defun %member-r (elm lst)
      (if lst
          (if (equal elm (car lst))
			  lst
              (%member-r elm (cdr lst)))))

    (defun member (elm &rest lsts)
      "Test if object is a member of any of the pure lists."
      (or (%member-r elm (car lsts))
          (if (cdr lsts)
              (apply #'member elm (cdr lsts)))))))

(define-test "MEMBER finds elements"
  ((if (member 's '(i) '(l i k e) '(l i s p))
	   t))
  t)

;(define-test "MEMBER finds elements with user predicate"
;  ((member "lisp" '("tre" "lisp") :test #'string=))
;  t)

(define-test "MEMBER detects foureign elements"
  ((member 'A '(l i s p)))
  nil)

(defun %member-if-r (pred lst)
  (if lst
      (if (funcall pred (car lst))
		  lst
          (%member-if-r pred (cdr lst)))))

(defun member-if (pred &rest lsts)
  "Test if predicate is true for any member of any of the pure lists."
  (or (%member-if-r pred (car lsts))
      (if (cdr lsts)
          (apply #'member-if pred (cdr lsts)))))
