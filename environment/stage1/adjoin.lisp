(functional adjoin)

(defun adjoin (obj lst &rest args)
  (? (apply #'member obj lst args)
     lst
     (. obj lst)))

(defmacro adjoin! (obj &rest place)
  `(= ,place. (adjoin ,obj ,@place)))

(define-test "ADJOIN doesn't add known member"
  ((adjoin 'i '(l i s p)))
  '(l i s p))

(define-test "ADJOIN adds new member"
  ((adjoin 'a '(l i s p)))
  '(a l i s p))
