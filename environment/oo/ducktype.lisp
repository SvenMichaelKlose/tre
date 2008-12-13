;;;;; TRE environment
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Ducktyped objects

(defconstant *ducktype-magic* '%%QUACK-QUACK!)
(defconstant *ducktype-classes* (make-hash-table))
(defconstant *ducktype-slothashes* (make-hash-table))
(defconstant *ducktype-members* (make-hash-table))

(defstruct ducktype-obj
  (magic *ducktype-magic*)
  (class nil)
  (slots nil)
  (members nil))

(defun ducktype-slothash-name (objname)
  ($ '%%DUCKTYPED-SLOTS- objname))

(defun %ducktype-inherit (cname bases)
  (with (base-members nil
	     base-methods nil)
   	(dolist (base bases)
	  (let bclass (href base *ducktype-classes*)
		(nconc base-members (class-members bclass))
		(nconc base-methods (class-methods bclass))))
	(make-ducktype-class :members base-members
				     	  :methods base-methods)))

(defun %ducktype-make-class (cname bases)
  (when (href cname *ducktype-classes*)
    (error "Class ~A already defined." cname))
  (setf (href cname *ducktype-classes*)
   		(if bases
			(%ducktype-inherit cname bases)
			(make-class))))

(defmacro defclass (class-name args &rest body)
  (with (cname (if (consp class-name)
				   class-name.
				   class-name)
		 bases (and (consp class-name)
				    .class-name))
	(%ducktype-make-class cname bases)
	(with (slothash (ducktype-slothash-name cname))
	  `(progn
	     (defvar ,slothash (make-hash-table))
	     (setf (href '__class ,slothash) ',cname)
		 (setf (href ',cname *ducktype-slothashes*) ,slothash)
	     ; Inherit base class slots.
	     ,@(mapcar (fn (with (baseslots (ducktype-slothash-name _))
	   				     `(dolist (i (hashkeys ,baseslots))
						    (setf (href i ,slothash)
								  (href i ,baseslots)))))
				   bases)
		 ,(thisify
		    *ducktype-classes*
	        `(defun ,cname (this ,@args)
			   (%thisify ,cname
		          ,@body)))))))

(defun %ducktype-assert-definition (what name class-name)
  (unless (href class-name *ducktype-classes*)
	(error "Definition of ~A ~A: class ~A is not defined."
		   what name class-name)))

(defmacro defmethod (class-name name args &rest body)
  (progn
    (%ducktype-assert-definition "method" name class-name)
    (setf (href name (href class-name *ducktype-slothashes*))
		  (eval `(function ,(thisify
		    				  *ducktype-classes*
							  `((this ,@args)
			           			  (%thisify ,class-name
			             			,@body))))))
    nil))

(defmacro defmember (class-name &rest names)
  (progn
    (%ducktype-assert-definition "member" class-name class-name)
    (setf (href class-name *ducktype-members*)
		  (append (href class-name *ducktype-members*) names))
    nil))

(defun %ducktype-assert (obj)
  (unless (arrayp obj)
    (error "ducktype object expected - not even an array"))
  (unless (eq *ducktype-magic* (ducktype-obj-magic obj))
    (error "ducktype object expected")))

(defun %slot-value (obj slot)
  (%ducktype-assert obj)
  (or (href slot (ducktype-obj-slots obj))
	  (href slot (ducktype-obj-members obj))))

(defun (setf %slot-value) (value obj slot)
  (%ducktype-assert obj)
  (setf (href slot (ducktype-obj-members obj)) value))

(defun %new (name &rest args)
  (let members (make-hash-table)
	(dolist (i (href name *ducktype-members*))
	  (clr (href i members)))
	(let this (make-ducktype-obj
				:class name
				:slots (href name *ducktype-slothashes*)
				:members members)
	  (apply (symbol-function name) this args)
	  this)))

(defmacro new (name &rest args)
  `(%new ',name ,@args))
