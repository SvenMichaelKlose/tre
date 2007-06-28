;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2006 Sven Klose <pixel@copei.de>
;;;;
;;;; List search

(defun member (elm &rest lsts)
  "Test if object is a member of any of the pure lists."
  (labels ((rec (elm lst)
             (when lst
               (or (equal elm (car lst))
                   (rec elm (cdr lst))))))
    (or (rec elm (car lsts))
        (if (cdr lsts)
          (apply #'member elm (cdr lsts))))))

(define-test "MEMBER finds elements"
  ((member 's '(i) '(l i k e) '(l i s p)))
  t)

(define-test "MEMBER detects foureign elements"
  ((member 'A '(l i s p)))
  nil)
