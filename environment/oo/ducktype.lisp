;;;;; TRE environment
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Ducktyped objects

(defvar *ducktype-magic* '%%QUACK-QUACK!)
(defvar *ducktype-classes* (make-hash-table))
(defvar *ducktype-slothashes* (make-hash-table))
(defvar *ducktype-members* (make-hash-table))

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
	  (let bclass (href *ducktype-classes* base)
		(nconc base-members (class-members bclass))
		(nconc base-methods (class-methods bclass))))
	(make-ducktype-obj :members base-members
				       :slots base-methods)))

(defun %ducktype-make-class (cname bases)
  (when (href *ducktype-classes* cname)
    (error "Class ~A already defined." cname))
  (setf (href *ducktype-classes* cname)
   		(if bases
			nil ;(%ducktype-inherit cname bases) XXX
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
	     (setf (href ,slothash '__class) ',cname)
		 (setf (href *ducktype-slothashes* ',cname) ,slothash)
	     ; Inherit base class slots.
	     ,@(mapcar (fn (with (baseslots (ducktype-slothash-name _))
	   				     `(dolist (i (hashkeys ,baseslots))
						    (setf (href ,slothash i)
								  (href ,baseslots i)))))
				   bases)
		 ,(thisify
		    *ducktype-classes*
	        `(defun ,cname (this ,@args)
			   (%thisify ,cname
		          ,@body)))))))

(defun %ducktype-assert-definition (what name class-name)
  (unless (href *ducktype-classes* class-name)
	(error "Definition of ~A ~A: class ~A is not defined."
		   what name class-name)))

(defmacro defmethod (class-name name args &rest body)
  (progn
    (%ducktype-assert-definition "method" name class-name)
    (setf (href (href *ducktype-slothashes* class-name) name)
		  (eval `(function ,(thisify
		    				  *ducktype-classes*
							  `((this ,@args)
			           			  (%thisify ,class-name
			             			,@body))))))
    nil))

(defmacro defmember (class-name &rest names)
  (progn
    (%ducktype-assert-definition "member" class-name class-name)
    (setf (href *ducktype-members* class-name )
		  (append (href *ducktype-members* class-name) names))
    nil))

(defun %ducktype-assert (obj)
  (unless (arrayp obj)
    (error "ducktype object expected - not even an array"))
  (unless (eq *ducktype-magic* (ducktype-obj-magic obj))
    (error "ducktype object expected")))

(defun %slot-value (obj slot)
  (%ducktype-assert obj)
  (or (href (ducktype-obj-slots obj) slot)
	  (href (ducktype-obj-members obj) slot)))

(defun slot-value (obj slot)
  (%ducktype-assert obj)
  (or (href (ducktype-obj-slots obj) slot)
	  (href (ducktype-obj-members obj) .slot.)))

(defun (setf %slot-value) (value obj slot)
  (%ducktype-assert obj)
  (setf (href (ducktype-obj-members obj) slot) value))

(defun (setf slot-value) (value obj slot)
  (%ducktype-assert obj)
  (setf (href (ducktype-obj-members obj) .slot.) value))

(defun %new (name &rest args)
  (let members (make-hash-table)
	(dolist (i (href *ducktype-members* name))
	  (clr (href members i)))
	(let this (make-ducktype-obj
				:class name
				:slots (href *ducktype-slothashes* name)
				:members members)
	  (apply (symbol-function name) this args)
	  this)))

(defmacro new (name &rest args)
  `(%new ',name ,@args))
