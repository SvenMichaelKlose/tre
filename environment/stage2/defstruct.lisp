;;;; TRE environment
;;;; Copyright (c) 2005-2009 Sven Klose <pixel@copei.de>

(defun %struct-option-keyword (e)
  (in? e :constructor))

(defun %struct-make-symbol (name options)
  (aif (assoc-value :constructor options)
       !.
       (make-symbol (string-concat "MAKE-" (symbol-name name)))))

(defun %struct-p-symbol (name)
  (make-symbol (string-concat (symbol-name name) "-P")))

(defun %struct-field-name (field)
  (if (consp field)
      field.
      field))

(defun %struct-make-args (fields)
  `(&key ,@(mapcar (fn (let n (%struct-field-name _)
						 `(,n ',n)))
				   fields)))

(defun %struct-make-init (fields g)
  (let form (make-queue)
    (do ((i fields .i)
	     (idx 1 (1+ idx)))
        ((endp i) (queue-list form))
      (let argname (%struct-field-name i.)
        (enqueue form `(setf (aref ,g ,idx)
							 (if (eq ,argname ',argname)
								 ,(when (consp i.)
									(second i.))
								 ,argname)))))))

(defun %struct-make (name fields options)
  (with (sym (%struct-make-symbol name options)
		 g (gensym)
         user-init (%struct-make-init fields g)
	     type-init `((setf (aref ,g 0) ',name)))
    `(defun ,sym ,(%struct-make-args fields)
       (let ,g (make-array ,(1+ (length fields)))
         ,@(if user-init
	           (nconc type-init user-init)
	           type-init)
	     ,g))))

(defun %struct-getter-symbol (name field)
  (make-symbol (string-concat (symbol-name name) "-" (symbol-name field))))

(defun %struct-single-get (name field index)
  (let sym (%struct-getter-symbol name field)
    `(progn
      (defun ,sym (arr)
        (aref arr ,index))
      (defun (setf ,sym) (val arr)
        (setf (aref arr ,index) val)))))

(defun %struct-getters (name fields)
  (with-queue form
    (do ((i fields .i)
	     (index 1 (1+ index)))
	    ((endp i) (queue-list form))
      (enqueue form
			   (%struct-single-get name (%struct-field-name i.) index)))))

(defun %struct-p (name)
  (let sym (%struct-p-symbol name)
    `(defun ,sym (arr)
       (and (arrayp arr) (eq (aref arr 0) ',name)))))

(defun %struct-sort-fields (fields-and-options)
  (with-queue (fields options)
    (mapcar (fn (if (and (consp _)
						 (%struct-option-keyword _.))
	                (enqueue options _)
	                (enqueue fields _)))
	        fields-and-options)
    (values (queue-list fields) (queue-list options))))

(defvar *struct-defs*)

(defun %struct-add-def (name def)
  (acons! name def *struct-defs*))

(defun %struct-def (name)
  (assoc-value name *struct-defs*))

(defun %struct-fields (name)
  (with-queue form
    (dolist (i (%struct-def name) (queue-list form))
      (enqueue form i.))))

(defun %defstruct-expander (name &rest fields-and-options)
  (multiple-value-bind (flds opts) (%struct-sort-fields fields-and-options)
    (%struct-add-def name flds)
    `(progn
      ,(%struct-make name flds opts)
      ,(%struct-p name)
      ,@(%struct-getters name flds)
      (defmacro ,(make-symbol (string-concat "WITH-" (symbol-name name))) (s &rest body)
		 `(with-struct ,name ,,s ,,@body))
      (defmacro ,(make-symbol (string-concat "DEF-" (symbol-name name))) (name args &rest body)
		 `(defun ,,name ,,args
            (with-struct ,name ,name ,,@body))))))

(defmacro defstruct (name &rest fields-and-options)
  (apply #'%defstruct-expander name fields-and-options))
