;;;; tré – Copyright (c) 2005–2009,2011–2014 Sven Michael Klose <pixel@copei.de>

(defun %nconc-0 (lsts)
  (when lsts
    (!? lsts.
	    (progn
		  (rplacd (last !) (%nconc-0 .lsts))
		  !)
		(%nconc-0 .lsts))))

(defun nconc (&rest lsts)
  (%nconc-0 lsts))

(defmacro nconc! (place &rest lsts)
  `(= ,place (nconc ,place ,@lsts)))

(define-test "NCONC works"
  ((nconc (copy-list '(l i)) (copy-list '(s p))))
  '(l i s p))

(define-test "NCONC works with empty lists"
  ((nconc nil (copy-list '(l i)) nil (copy-list '(s p)) nil))
  '(l i s p))
