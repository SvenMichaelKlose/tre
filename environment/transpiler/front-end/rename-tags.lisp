;;;;; TRE to C transpiler
;;;;; Copyright (c) 2009-2011 Sven Klose <pixel@copei.de>

(defun rename-body-tags-get-expr-0 (x)
  (if
    (%%vm-go? x)     (error "VM-GO in argument list")
	(%%vm-go-nil? x) (error "VM-GO-NIL in argument list")
	(%%vm-go-not-nil? x) (error "VM-GO-NOT-NIL in argument list")
	(lambda? x)      (rename-body-tags-get (lambda-body x))
	(%%vm-scope? x)  (rename-body-tags-get .x)
    (rename-body-tags-get-expr x)))

(defun rename-body-tags-get-expr (x)
  (if
	(atom x)     nil
    (%quote? x.) (rename-body-tags-get-expr .x)
	(append (rename-body-tags-get-expr-0 x.)
		    (rename-body-tags-get-expr .x))))

(defun rename-body-tags-get-0 (x)
  (if
	(number? x)     (list (cons x (make-compiler-tag)))
	(lambda? x)     (rename-body-tags-get (lambda-body x))
	(%%vm-scope? x) (rename-body-tags-get .x)
	(%quote? x)     nil
    (rename-body-tags-get-expr x)))

(defun rename-body-tags-get (x)
  (if
	(atom x)       nil
    (%quote? x.)  (rename-body-tags-get .x)
	(append (rename-body-tags-get-0 x.)
		    (rename-body-tags-get .x))))

(defun rename-body-tags-set-expr-0 (x renamed)
  (if
	(%quote? x)		 x
	(%%vm-go? x)	 (error "VM-GO in argument list")
	(%%vm-go-nil? x) (error "VM-GO-NIL in argument list")
	(%%vm-go-not-nil? x) (error "VM-GO-NOT-NIL in argument list")
	(lambda? x)		 (copy-lambda x :body (rename-body-tags-set (lambda-body x) renamed))
	(%%vm-scope? x)  `(%%vm-scope ,@(rename-body-tags-set .x renamed))
	(rename-body-tags-set-expr x renamed)))

(defun rename-body-tags-set-expr (x renamed)
  (if
	(atom x) x
	(cons (rename-body-tags-set-expr-0 x. renamed)
		  (rename-body-tags-set-expr .x renamed))))

(defun rename-body-tags-set-0 (x renamed)
  (if
	(number? x)	      (or (assoc-value x renamed :test #'=)
				  	  	(error "didn't gather tag ~A" x.))
	(%quote? x)       x
	(%%vm-go? x)      `(%%vm-go ,(or (assoc-value .x. renamed :test #'=)
						   		     (error "didn't gather tag ~A for VM-GO" x)))
	(%%vm-go-nil? x)  `(%%vm-go-nil ,.x.
				   	 	  		    ,(or (assoc-value ..x. renamed :test #'=)
						       		     (error "didn't gather tag ~A VM-GO-NIL" x)))
	(%%vm-go-not-nil? x)  `(%%vm-go-not-nil ,.x.
				   	 	  		            ,(or (assoc-value ..x. renamed :test #'=)
						       		             (error "didn't gather tag ~A VM-GO-NOT-NIL" x)))
	(lambda? x) 	  (copy-lambda x
				  		  :body (rename-body-tags-set (lambda-body x) renamed))
	(%%vm-scope? x)   `(%%vm-scope ,@(rename-body-tags-set .x renamed))
	(rename-body-tags-set-expr x renamed)))

(defun rename-body-tags-set (x renamed)
  (if
	(atom x) x
	(cons (rename-body-tags-set-0 x. renamed)
		  (rename-body-tags-set .x renamed))))

(defun rename-body-tags (x)
  (rename-body-tags-set x (rename-body-tags-get x)))
