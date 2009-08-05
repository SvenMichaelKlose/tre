;;;;; TRE environment
;;;;; Copyright (C) 2005-2006,2008 Sven Klose <pixel@copei.de>

(defun %member-r (elm lst)
  (if lst
    (or (equal elm lst.)
        (%member-r elm .lst))))

(defun member (elm &rest lsts)
  "Test if object is a member of any of the pure lists."
  (let x .lsts
    (or (%member-r elm x)
        (when x
          (apply #'member elm x)))))

;(define-test "MEMBER finds elements"
;  ((member 's '(i) '(l i k e) '(l i s p)))
;  t)

;(define-test "MEMBER detects foureign elements"
;  ((member 'A '(l i s p)))
;  nil)
