;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2006 Sven Klose <pixel@copei.de>
;;;;
;;;; Structures

(defun %struct-option-keyword (e)
  (in? e :constructor))

(defun %struct-make-symbol (name options)
  (aif (assoc :constructor options)
     (car !)
     (make-symbol (string-concat "MAKE-" (symbol-name name)))))

(defun %struct-p-symbol (name)
  (make-symbol (string-concat (symbol-name name) "-P")))

(defun %struct-make-args (fields)
  `(&key ,@fields))

(defun %struct-make-init (fields)
  (let ((form (make-queue)))
    (do ((i fields (cdr i))
	 (idx 1 (1+ idx)))
        ((endp i) (queue-list form))
      (if (consp (car i))
        (enqueue form `(setf (elt a ,idx) ,(caar i)))
        (enqueue form `(setf (elt a ,idx) ,(car i)))))))

(defun %struct-make (name fields options)
  (let ((sym (%struct-make-symbol name options))
        (user-init (%struct-make-init fields))
	(type-init `((setf (elt a 0) ',name))))
    `(defun ,sym ,(%struct-make-args fields)
       (let ((a (make-array ,(1+ (length fields)))))
         ,@(if user-init
	     (nconc type-init user-init)
	     type-init)
	 a))))

(defun %struct-getter-symbol (name field)
  (make-symbol (string-concat (symbol-name name) "-" (symbol-name field))))

(defun %struct-field-name (field)
  (if (consp field)
    (car field)
    field))

(defun %struct-single-get (name field index)
  (let ((sym (%struct-getter-symbol name field)))
    `(progn
      (defun ,sym (arr)
        (elt arr ,index))
      (defun (setf ,sym) (val arr)
        (setf (elt arr ,index) val)))))

(defun %struct-getters (name fields)
  (with-queue form
    (do ((i fields (cdr i))
	     (index 1 (1+ index)))
	    ((endp i) (queue-list form))
      (enqueue form (%struct-single-get name (%struct-field-name (car i)) index)))))

(defun %struct-p (name)
  (let ((sym (%struct-p-symbol name)))
    `(defun ,sym (arr)
        (and (arrayp arr) (eq (elt arr 0) ,name)))))

(defun %struct-sort-fields (fields-and-options)
  "Split list into fields and options."
  (with-queue (f o)
    (mapcar #'(lambda (x)
	        (if (and (consp x) (%struct-option-keyword (car x)))
	          (enqueue o x)
	          (enqueue f x)))
	    fields-and-options)
    (values (queue-list f) (queue-list o))))

(defvar *struct-defs*)

(defun %struct-add-def (name def)
  (acons! name def *struct-defs*))

(defun %struct-def (name)
  (assoc name *struct-defs*))

(defun %struct-name (obj)
  (if (not (arrayp obj))
    (error "object is not a struct")
    (elt 0 obj)))

(defun %struct-fields (name)
  (with-queue form
    (dolist (i (%struct-def name) (queue-list form))
      (enqueue form (car i)))))

(defmacro with-struct (name s &rest body)
  (with-gensym g
    `(with (,g ,s
			,@(mapcan
				#'((x)
				,x (,(make-symbol (string-concat (symbol-name name) "-" (symbol-name x) ,g)))
				(%struct-fields s))))
	   ,@body)))

(defmacro defstruct (name &rest fields-and-options)
  "Define new structure."
  (multiple-value-bind (flds opts) (%struct-sort-fields fields-and-options)
    (%struct-add-def name flds)
    `(progn
      ,(%struct-make name flds opts)
      ,(%struct-p name)
      ,@(%struct-getters name flds)
      (defmacro ,(make-symbol (string-concat "WITH-" (symbol-name name))) (s &rest body)
		 `(with-struct ,,name ,s ,@body)))))
