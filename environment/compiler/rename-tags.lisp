;;;;; TRE to C transpiler
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Renaming body tags after lambda-expansion

(defun rename-body-tags-get-expr (x)
  (if
	(atom x)
	  nil
    (%quote? x.)
	  (rename-body-tags-get-expr .x)
	(append (if
			  (vm-go? x.)
	  		    (error "VM-GO in argument list")
			  (vm-go-nil? x.)
	  		    (error "VM-GO-NIL in argument list")
			  (lambda? x.)
	  			(rename-body-tags-get (lambda-body x.))
			  (vm-scope? x.)
			    (rename-body-tags-get (cdr x.))
			  (rename-body-tags-get-expr x.))
		    (rename-body-tags-get-expr .x))))

(defun rename-body-tags-get (x)
  (if
	(atom x)
	  nil
    (%quote? x.)
	  (rename-body-tags-get .x)
	(append (if
			  (numberp x.)
	  			(list (cons x. (gensym-number)))
			  (lambda? x.)
	  			(rename-body-tags-get (lambda-body x.))
			  (vm-scope? x.)
			    (rename-body-tags-get (cdr x.))
			  (%quote? x.)
				nil
			  (rename-body-tags-get-expr x.))
		    (rename-body-tags-get .x))))

(defun rename-body-tags-set-expr (x renamed)
  (if
	(atom x)
	  x
	(cons (if
			(%quote? x.)
	  		  x.
			(vm-go? x.)
	  		  (error "VM-GO in argument list")
			(vm-go-nil? x.)
	  		  (error "VM-GO-NIL in argument list")
			(lambda? x.)
	  		  `#'(,@(lambda-funinfo-and-args x.)
				  ,@(rename-body-tags-set (lambda-body x.) renamed))
			(vm-scope? x.)
			  `(vm-scope ,@(rename-body-tags-set (cdr x.) renamed))
			(rename-body-tags-set-expr x. renamed))
		  (rename-body-tags-set-expr .x renamed))))

(defun rename-body-tags-set (x renamed)
  (if
	(atom x)
	  x
	(cons (if
			(numberp x.)
	  		  (or (assoc-value x. renamed :test #'=)
				  (error "didn't gather tag ~A" x.))
			(%quote? x.)
	  		  x.
			(vm-go? x.)
	  		  `(vm-go ,(or (assoc-value (second x.) renamed :test #'=)
						   (error "didn't gather tag ~A for VM-GO" x.)))
			(vm-go-nil? x.)
	  		  `(vm-go-nil ,(second x.)
				   	 	  ,(or (assoc-value (third x.) renamed :test #'=)
						       (error "didn't gather tag ~A VM-GO-NIL" x.)))
			(lambda? x.)
	  		  `#'(,@(lambda-funinfo-and-args x.)
				  ,@(rename-body-tags-set (lambda-body x.) renamed))
			(vm-scope? x.)
			  `(vm-scope ,@(rename-body-tags-set (cdr x.) renamed))
			(rename-body-tags-set-expr x. renamed))
		  (rename-body-tags-set .x renamed))))

(defun rename-body-tags (x)
  (rename-body-tags-set x (rename-body-tags-get x)))
