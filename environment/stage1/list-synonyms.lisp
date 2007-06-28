;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (c) 2006-2007 Sven Klose <pixel@copei.de>

(defun %make-cdr (i)
  (if (= i 0)
    'x
    `(cdr ,(%make-cdr (1- i)))))

(defmacro %make-list-synonyms ()
  `(block nil
     ,@(let ((l))
         (dolist-indexed (fun i '(first second third fourth fifth
		 	          sixth seventh eighth ninth tenth) l)
         (push `(defun ,fun (x)
	          (car ,(%make-cdr i)))
                l)))))

(%make-list-synonyms)
