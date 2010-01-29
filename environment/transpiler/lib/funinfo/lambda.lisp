;;;;; TRE compiler
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

;;;;; LAMBDA FUNINFO

(defvar *funinfos* (make-hash-table :test #'eq))
(defvar *funinfos-reverse* (make-hash-table :test #'eq))

(defun make-lambda-funinfo (fi)
  (when (href *funinfos-reverse* fi)
	(error "funinfo already memorized"))
  (setf (href *funinfos-reverse* fi) t)
  (let g (funinfo-sym fi)
	(transpiler-add-obfuscation-exceptions *current-transpiler* g)
	(setf (href *funinfos* g) fi)
	`(%funinfo ,g)))

(defun make-lambda-funinfo-if-missing (x fi)
  (or (lambda-funinfo-expr x)
	  (make-lambda-funinfo fi)))

(defun make-missing-lambda-funinfo (x fi)
  (when (lambda-funinfo-expr x)
	(error "already has funinfo expression"))
  (make-lambda-funinfo fi))

(defun get-lambda-funinfo-by-sym (x)
  (href *funinfos* x))

(defun get-lambda-funinfo (x)
  (with (fi-sym (lambda-funinfo x)
         fi	    (get-lambda-funinfo-by-sym fi-sym))
    (unless (or (and (not fi)
					 (not fi-sym))
				(and fi
				 	 (eq fi-sym (funinfo-sym fi))))
	  (print fi)
	  (print x)
	  (print (lambda-funinfo x))
	  (error "couldn't get funinfo"))
	fi))
