;;;;; tré - Copyright (c) 2005-2009,2011-2012 Sven Michael Klose <pixel@copei.de>

(defvar *setf-function?* #'%setf-function?)

(defun %setf-make-symbol (fun)
  (make-symbol (string-concat "%%USETF-" (symbol-name fun))))

(defun %setf-complement (p val)
  (if (or (atom p)
		  (%slot-value? p)
		  (slot-value? p))
	  (progn
		(if (member p *constants* :test #'eq)
		    (%error "cannot set constant"))
      	(list 'setq p val))
      (let* ((fun (car p))
	         (args (cdr p))
	         (setfun (%setf-make-symbol fun)))
        (if (funcall *setf-function?* setfun)
			(if (member (car args) *constants* :test #'eq)
		    	(%error (string-concat "cannot set constant " (symbol-name (car args))))
	            `(,setfun ,val ,@args))
            (progn
              (print p)
	          (%error "place not settable"))))))

(defun %setf (args)
  (if (not (cdr args))
    (%error "pairs expected"))
    (cons
      (%setf-complement (car args) (cadr args))
      (if (cddr args)
        (%setf (cddr args)))))

(defmacro setf (&rest args)
  (if (not args)
    (%error "arguments expected")
    (if (= 1 (length args))
      `(setf ,(car args)) ; Keep for DEFUN argument name.
      `(progn
		 ,@(%setf args)))))
