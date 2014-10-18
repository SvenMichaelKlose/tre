;;;;; tré – Copyright (c) 2005–2009,2011–2013 Sven Michael Klose <pixel@copei.de>

(functional append)

(defun append (&rest lsts)
  (when lsts
	(? (car lsts)
   	   (let n (copy-list (car lsts))
         (rplacd (last n) (apply #'append (cdr lsts)))
         n)
	   (apply #'append (cdr lsts)))))

(defmacro append! (place &rest args)
  `(= ,place (append ,place ,@args)))

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
