;;;;; TRE environment
;;;;; Copyright (C) 2005-2006,2008 Sven Klose <pixel@copei.de>

(defun %member-r (elm lst)
  (if lst
    (or (equal elm (car lst))
        (%member-r elm (cdr lst)))))

(defun member (elm &rest lsts)
  "Test if object is a member of any of the pure lists."
  (or (%member-r elm (car lsts))
      (if (cdr lsts)
          (apply #'member elm (cdr lsts)))))

;(define-test "MEMBER finds elements"
;  ((member 's '(i) '(l i k e) '(l i s p)))
;  t)

;(define-test "MEMBER detects foureign elements"
;  ((member 'A '(l i s p)))
;  nil)
