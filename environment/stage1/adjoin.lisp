;;;;; tré – Copyright (c) 2005–2009,2011–2013 Sven Michael Klose <pixel@copei.de>

(functional adjoin)

(defun adjoin (obj lst &rest args)
  (? (apply #'member obj lst args)
     lst
     (cons obj lst)))

(defmacro adjoin! (obj &rest place)
  `(= ,(car place) (adjoin ,obj ,@place)))

(define-test "ADJOIN doesn't add known member"
  ((adjoin 'i '(l i s p)))
  '(l i s p))

(define-test "ADJOIN adds new member"
  ((adjoin 'a '(l i s p)))
  '(a l i s p))
