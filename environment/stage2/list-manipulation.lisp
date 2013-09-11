;;;;; tré – Copyright (c) 2005–2009,2011–2013 Sven Michael Klose <pixel@copei.de>

(functional append adjoin reverse)

(defun append (&rest lsts)
  (when lsts
	(? (car lsts) ; Ignore empty lists.
   	   (let n (copy-list (car lsts))
         (rplacd (last n) (apply #'append (cdr lsts)))
         n)
	   (apply #'append (cdr lsts)))))

(defmacro append! (place &rest args)
  `(= ,place (append ,place ,@args)))

(defun %nconc-0 (lsts)
  (when lsts
    (!? (car lsts)
	    (progn
		  (rplacd (last !) (%nconc-0 (cdr lsts)))
		  !)
		(%nconc-0 (cdr lsts)))))

(defun adjoin (obj lst &rest args)
  (? (apply #'member obj lst args)
     lst
     (cons obj lst)))

(defmacro adjoin! (obj &rest place)
  `(= ,(car place) (adjoin ,obj ,@place)))

(defun reverse (lst)
  (alet nil
    (dolist (i lst !)
      (push i !))))

(defun nconc (&rest lsts)
  (%nconc-0 lsts))

(defmacro nconc! (place &rest lsts)
  `(= ,place (nconc ,place ,@lsts)))

(define-test "COPY-LIST works"
  ((copy-list '(l i s p)))
  '(l i s p))

(define-test "APPEND works with two lists"
  ((append '(l i) '(s p)))
  '(l i s p))

(define-test "APPEND works with empty lists"
  ((append nil '(l i) nil '(s p) nil))
  '(l i s p))

(define-test "APPEND works with three lists"
  ((append '(i) '(l i k e) '(l i s p)))
  '(i l i k e l i s p))

(define-test "APPEND copies last"
  ((let tmp '(s)
     (eq tmp (cdr (append '(l) tmp)))))
  nil)

(define-test "NCONC works"
  ((nconc (copy-list '(l i)) (copy-list '(s p))))
  '(l i s p))

(define-test "NCONC works with empty lists"
  ((nconc nil (copy-list '(l i)) nil (copy-list '(s p)) nil))
  '(l i s p))

(define-test "ADJOIN doesn't add known member"
  ((adjoin 'i '(l i s p)))
  '(l i s p))

(define-test "ADJOIN adds new member"
  ((adjoin 'a '(l i s p)))
  '(a l i s p))

(define-test "REVERSE works"
  ((reverse '(1 2 3)))
  '(3 2 1))
