;;;;; tré – Copyright (c) 2006–2008,2011–2012 Sven Michael Klose <pixel@copei.de>

(defconstant *first-to-tenth*
  '(first second third fourth fifth sixth seventh eighth ninth tenth))

(defun %make-cdr (i)
  (? (== i 0)
     'x
     `(cdr ,(%make-cdr (1- i)))))

(defmacro %make-list-synonyms ()
  `(block nil
     ,@(let* ((l nil)
			  (i 0))
         (mapcar #'((name)
           		     (push `(block nil
                              (functional ,name)
							  (defun ,name (x)
	                            (car ,(%make-cdr i)))
						      (defun (setf ,name) (v x)
							    (rplaca ,(%make-cdr i) v)))
						 l)
				   (incf i))
			 *first-to-tenth*)
		 l)))

(%make-list-synonyms)

(functional rest)

(defun rest (x)
  (cdr x))
