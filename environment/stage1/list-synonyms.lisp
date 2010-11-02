;;;; TRE environment
;;;; Copyright (c) 2006-2008,2010 Sven Klose <pixel@copei.de>

(defconstant *first-to-tenth*
  '(first second third fourth fifth sixth seventh eighth ninth tenth))

(defun %make-cdr (i)
  (if (= i 0)
      'x
      `(cdr ,(%make-cdr (1- i)))))

(defmacro %make-list-synonyms ()
  `(block nil
     ,@(let* ((l nil)
			  (i 0))
         (mapcar #'((name)
           		   (push `(block nil
							(defun ,name (x)
	                          (car ,(%make-cdr i)))
						    (defun (setf ,name) (v x)
							  (rplaca ,(%make-cdr i) v)))
						 l)
				   (incf i))
			 *first-to-tenth*)
		 l)))

(%make-list-synonyms)

(defun rest (x)
  (cdr x))
