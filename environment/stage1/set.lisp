;;;; TRE environment
;;;; Copyright (C) 2005-2009 Sven Klose <pixel@copei.de>
;;;;
;;;; SETF macro

(defun %setf-functionp (x)
  (functionp (eval `(function ,x))))

(defvar *setf-immediate-slot-value* nil)
(defvar *setf-functionp* #'%setf-functionp)

(defun %setf-make-symbol (fun)
  (make-symbol (string-concat "%%USETF-" (symbol-name fun))))

(defun %slot-value? (x)
  (and (consp x)
	   (eq '%SLOT-VALUE (car x))
	   (consp (cdr x))))

(defun slot-value? (x)
  (and (consp x)
	   (eq 'SLOT-VALUE (car x))
	   (consp (cdr x))))

(defun %setf-complement (p val)
  (if (or (atom p)
		  (and *setf-immediate-slot-value*
			   (or (%slot-value? p)
				   (slot-value? p))))
	  (progn
		(if (member p *constants*)
		    (%error "cannot set constant"))
      	(list 'setq p val))
      (let* ((fun (car p))
	         (args (cdr p))
	         (setfun (%setf-make-symbol fun)))
        (if (funcall *setf-functionp* setfun)
			(if (member (car args) *constants*)
		    	(%error "cannot set constant")
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
      `(%%defunsetf ,(car args)) ; Keep for DEFUN argument name.
      `(progn
		 ,@(%setf args)))))

(defun (setf symbol-function) (fun sym)
  (%set-atom-fun sym fun)
  fun)
