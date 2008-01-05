;;;;; nix operating system project ;;;;; lisp compiler
;;;;; Copyright (c) 2006-2008 Sven Klose <pixel@copei.de>
;;;;; 
;;;;; Breaks up nested expressions into lists of assignments.

(defvar *expexsym-counter* 0)

;; Returns newly created, unique symbol.
(defun expex-sym ()
  (setf *expexsym-counter* (+ 1 *expexsym-counter*))
  (make-symbol (string-concat "~E" (string *expexsym-counter*))))

(defun expex-vmscope (x)
  (with (e (expex-body (cdr x))
    	 s (expex-sym))
    (cons (aif (butlast e)
			   (nconc ! `((,s ,(car (last e)))))
               `((,s ,(car e))))
		  s)))

(defun expex-assignment (x)
  (if (atom x)
	  (cons nil x)
  	  (if (vm-scope? x)
	      (expex-vmscope x)
  	      (with (s (expex-sym)
				 (pre main) (expex-toplevel x))
    	    (cons (nconc pre `((,s ,@main)))
		  	      s)))))

(defun expex-args (x)
  (with ((pre main) (assoc-splice (mapcar #'expex-assignment (cdr x))))
    (values (apply #'nconc pre)
			main)))

(defun expex-able? (x)
  (not (or (atom x)
           (in? (car x) '%funref 'vm-go 'vm-go-nil '%stack 'quote))))

(defun expex-expr (x)
  (with ((pre newargs) (expex-args x))
    (values pre (list (if (eq (car x) '%setq)
						  newargs
						  (cons (car x) newargs))))))

(defun expex-toplevel (x)
  (if (not (expex-able? x))
	  (values nil (list x))
  	  (if (vm-scope? x)
	      (values nil (expex-body (cdr x)))
	      (expex-expr x))))

(defun expex-body (x)
  (when x
     (with ((pre main) (expex-toplevel (car x)))
       (nconc pre main (expex-body (cdr x))))))
