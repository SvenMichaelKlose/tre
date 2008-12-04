;;;; TRE environment
;;;; Copyright (C) 2005-2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Structures

(defun %struct-option-keyword (e)
  (in? e :constructor))

(defun %struct-make-symbol (name options)
  (aif (cdr (assoc :constructor options))
     (car !)
     (make-symbol (string-concat "MAKE-" (symbol-name name)))))

(defun %struct-p-symbol (name)
  (make-symbol (string-concat (symbol-name name) "-P")))

(defun %struct-make-args (fields)
  `(&key ,@fields))

(defun %struct-make-init (fields g)
  (with (form (make-queue))
    (do ((i fields (cdr i))
	     (idx 1 (1+ idx)))
        ((endp i) (queue-list form))
      (if (consp (car i))
        (enqueue form `(setf (elt ,g ,idx) ,(caar i)))
        (enqueue form `(setf (elt ,g ,idx) ,(car i)))))))

(defun %struct-make (name fields options)
  (with (sym (%struct-make-symbol name options)
		 g (gensym)
         user-init (%struct-make-init fields g)
	     type-init `((setf (elt ,g 0) ',name)))
    `(defun ,sym ,(%struct-make-args fields)
       (with (,g (make-array ,(1+ (length fields))))
         ,@(if user-init
	           (nconc type-init user-init)
	           type-init)
	     ,g))))

(defun %struct-getter-symbol (name field)
  (make-symbol (string-concat (symbol-name name) "-" (symbol-name field))))

(defun %struct-field-name (field)
  (if (consp field)
      (car field)
      field))

(defun %struct-single-get (name field index)
  (with (sym (%struct-getter-symbol name field))
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
  (with (sym (%struct-p-symbol name))
    `(defun ,sym (arr)
       (and (arrayp arr) (eq (elt arr 0) ,name)))))

(defun %struct-sort-fields (fields-and-options)
  "Split list into fields and options."
  (with-queue (f o)
    (mapcar #'((x)
	             (if (and (consp x) (%struct-option-keyword (car x)))
	                 (enqueue o x)
	                 (enqueue f x)))
	        fields-and-options)
    (values (queue-list f) (queue-list o))))

(defvar *struct-defs*)

(defun %struct-add-def (name def)
  (acons! name def *struct-defs*))

(defun %struct-def (name)
  (cdr (assoc name *struct-defs*)))

(defun %struct-name (obj)
  (if (not (arrayp obj))
      (%error "object is not a struct")
      (elt 0 obj)))

(defun %struct-fields (name)
  (with-queue form
    (dolist (i (%struct-def name) (queue-list form))
      (enqueue form (car i)))))

(defmacro defstruct (name &rest fields-and-options)
  "Define new structure."
  (multiple-value-bind (flds opts) (%struct-sort-fields fields-and-options)
    (%struct-add-def name flds)
    `(progn
      ,(%struct-make name flds opts)
      ,(%struct-p name)
      ,@(%struct-getters name flds)
      (defmacro ,(make-symbol (string-concat "WITH-" (symbol-name name))) (s &rest body)
		 `(with-struct ,name ,,s ,,@body)))))
