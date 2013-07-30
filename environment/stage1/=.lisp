;;;;; tré – Copyright (c) 2005–2009,2011–2013 Sven Michael Klose <pixel@copei.de>

(defvar *=-function?* #'%=-function?)

(defun %=-make-symbol (fun)
  (make-symbol (string-concat "=-" (symbol-name fun))))

(defun %=-complement (p val)
  (? (| (atom p)
	    (%slot-value? p)
	    (slot-value? p))
	 (progn
	   (? (member p *constants* :test #'eq)
		  (error "Cannot set constant ~A." p))
       (list 'setq p val))
     (let* ((fun (car p))
	        (args (cdr p))
	        (setfun (%=-make-symbol fun)))
       (? (funcall *=-function?* setfun)
		  (? (member (car args) *constants* :test #'eq)
		   	 (error "Cannot set constant ~A." args)
	         `(,setfun ,val ,@args))
          (error "Place ~A isn't settable." p)))))

(defun %= (args)
  (? (not (cdr args))
     (error "Pair expected instead of single ~A." (car args))
     (cons (%=-complement (car args) (cadr args))
           (? (cddr args)
              (%= (cddr args))))))

(defmacro = (&rest args)
  (? args
    (? (== 1 (length args))
       `(= ,(car args))
       `(progn
		  ,@(%= args)))
    (error "Arguments expected.")))
