;;;;; TRE compiler
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(defvar *funinfos* (make-hash-table :test #'eq))
(defvar *funinfos-reverse* (make-hash-table :test #'eq))

(defun make-lambda-funinfo (fi)
  (when (href *funinfos-reverse* fi)
	(error "funinfo already memorized"))
  (setf (href *funinfos-reverse* fi) t)
  (let g (funinfo-sym fi)
	(setf (href *funinfos* g) fi)
	`(%funinfo ,g)))

(defun make-lambda-funinfo-if-missing (x fi)
  (or (lambda-funinfo-expr x)
	  (make-lambda-funinfo fi)))

(defun make-missing-lambda-funinfo (x fi)
  (when (lambda-funinfo-expr x)
	(error "already has funinfo expression"))
  (make-lambda-funinfo fi))

(defun lambda-head-w/-missing-funinfo (x fi)
  `(,@(make-lambda-funinfo-if-missing x fi)
	,(lambda-args x)))

(defun lambda-w/-missing-funinfo (x fi)
  `#'(,@(lambda-head-w/-missing-funinfo x fi)
		  ,@(lambda-body x)))

(defun get-funinfo-by-sym (x)
  (href *funinfos* x))

(defun get-lambda-funinfo (x)
  (with (fi-sym (lambda-funinfo x)
         fi	    (get-funinfo-by-sym fi-sym))
    (unless (or (not fi fi-sym)
				(and fi
				 	 (eq fi-sym (funinfo-sym fi))))
	  (print fi)
	  (print x)
	  (print (lambda-funinfo x))
	  (error "couldn't get funinfo"))
	fi))

(defun funinfo-expr-symbol (x)
  (and (eq '%funinfo x.) .x.))

(defun split-funinfo-and-args (x)
  (let fi-sym (funinfo-expr-symbol x)
    (values fi-sym (? fi-sym ..x x))))
