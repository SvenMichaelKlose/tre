;;;; TRE environment
;;;; Copyright (C) 2005-2009 Sven Klose <pixel@copei.de>
;;;;
;;;; SETF macro

(defun %setf-functionp (x)
  (functionp (eval `(function ,x))))

(defvar *setf-immediate-slot-value* nil)
(defvar *setf-functionp* #'%setf-functionp)

;; Assign evaluated value of argument y to variable x.
(defmacro set (x y)
  `(setq ,(eval x) ,y))

(defun %setf-make-symbol (fun)
  (make-symbol (string-concat "%%USETF-" (symbol-name fun))))

(defun %slot-value? (x)
  (and (consp x)
	   (eq '%SLOT-VALUE (car x))))

(defun %setf-complement (p val)
  (if (or (atom p)
		  (and *setf-immediate-slot-value*
			   (%slot-value? p)))
	  (progn
		(if (member p *constants*)
		    (%error "cannot set constant"))
      	(list 'setq p val))
      (let* ((fun (car p))
	         (args (cdr p))
	         (setfun (%setf-make-symbol fun)))
        (if (funcall *setf-functionp* setfun)
	        (let g (gensym)
			   (if (member (car args) *constants*)
		    	   (%error "cannot set constant"))
              `(progn
	             (let ,g ,val
	               (,setfun ,g ,@args)
	               ,g)))
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
  (%set-atom-fun sym fun))
