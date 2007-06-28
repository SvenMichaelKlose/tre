;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
;;;;
;;;; List manipulation functions

(defun append (&rest lsts)
  "Concatenate lists. All list, except the last, are copied."
  (if (not (cdr lsts))
    (car lsts)
    (let ((n (copy-list (car lsts))))
      (rplacd (last n) (apply #'append (cdr lsts)))
      n)))

(define-test "APPEND works with two lists"
  ((append '(l i) '(s p)))
  '(l i s p))

(define-test "APPEND works with three lists"
  ((append '(i) '(l i k e) '(l i s p)))
  '(i l i k e l i s p))

(define-test "APPEND doesn't copy last"
  ((let ((tmp '(s)))
     (eq tmp (cdr (append '(l) tmp)))))
  t)

(defun nconc (&rest lsts)
  "Concatenate list arguments destructively."
  (do ((l lsts (cdr l)))
      ((endp l) (car lsts))
    (rplacd (last (car l)) (cadr l))))

(define-test "NCONC works"
  ((nconc (copy-list '(l i)) (copy-list '(s p))))
  '(l i s p))

(defun adjoin (obj lst &rest args)
  "Returns LST if OBJ is a member of LST or ARGS or returns new head of
   list containing OBJ."
  (if (apply #'member obj lst args)
    lst
    (cons obj lst)))

(define-test "ADJOIN works returns with member"
  ((adjoin 'i '(l i s p)))
  '(l i s p))

(define-test "ADJOIN works adds new member"
  ((adjoin 'a '(l i s p)))
  '(a l i s p))

(defun reverse (lst)
  "Return new reversed list with same elements."
  (let ((nl nil))
    (dolist (i lst nl)
      (push i nl))))

(define-test "REVERSE works"
  ((reverse '(1 2 3)))
  '(3 2 1))
