;;;;; tré - Copyright (c) 2005-2009,2011-2012 Sven Michael Klose <pixel@copei.de>

(defun %struct-option-keyword (e)
  (in? e :constructor))

(defun %struct-make-symbol (name options)
  (aif (assoc-value :constructor options)
       !.
       ($ "MAKE-" name)))

(defun %struct?-symbol (name)
  ($ name "?"))

(defun %struct-field-name (field)
  (? (cons? field)
     field.
     field))

(defun %struct-make-args (fields)
  `(&key ,@(mapcar (fn (let n (%struct-field-name _)
						 `(,n ',n)))
				   fields)))

(defun %struct-make-init (fields g)
  (let index 0
    (mapcar (fn let argname (%struct-field-name _)
                 `(setf (aref ,g ,(1+! index))
						(? (eq ,argname ',argname)
						   ,(and (cons? _)
							     (cadr _))
						  ,argname)))
            fields)))

(defun %struct-make (name fields options)
  (with (sym (%struct-make-symbol name options)
		 g (gensym)
         user-init (%struct-make-init fields g)
	     type-init `((setf (aref ,g 0) ',name)))
    `(defun ,sym ,(%struct-make-args fields)
       (let ,g (make-array ,(1+ (length fields)))
         ,@(? user-init
	          (nconc type-init user-init)
	          type-init)
	     ,g))))

(defun %struct-getter-symbol (name field)
  ($ name "-" field))

(defun %struct-assertion (name sym)
  (when *assert*
    `((unless (,(%struct?-symbol name) arr)
        (error ,(string-concat "In " (symbol-name sym) ": Expected a " (symbol-name name) " structure instead of ~A") arr)))))

(defun %struct-single-get (name field index)
  (let sym (%struct-getter-symbol name field)
    `(progn
       (functional ,sym)
       (defun ,sym (arr)
         ,@(%struct-assertion name sym)
         (aref arr ,index))
       (defun (setf ,sym) (val arr)
         ,@(%struct-assertion name sym)
         (setf (aref arr ,index) val)))))

(defun %struct-getters (name fields)
  (let index 0
    (mapcar (fn %struct-single-get name (%struct-field-name _) (1+! index)) fields)))

(defun %struct? (name)
  (let sym (%struct?-symbol name)
    `(defun ,sym (arr)
       (and (array? arr)
            (eq ',name (aref arr 0))))))

(defun %struct-sort-fields (fields-and-options)
  (with-queue (fields options)
    (map (fn (? (and (cons? _)
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
  (carlist (%struct-def name)))

(defun %defstruct-expander (name &rest fields-and-options)
  (multiple-value-bind (flds opts) (%struct-sort-fields fields-and-options)
    (%struct-add-def name flds)
    `(progn
      ,(%struct-make name flds opts)
      ,(%struct? name)
      ,@(%struct-getters name flds)
      (defmacro ,($ "WITH-" name) (s &rest body)
		 `(with-struct ,name ,,s ,,@body))
      (defmacro ,($ "DEF-" name) (name args &rest body)
		 `(defun ,,name ,,args
            (with-struct ,name ,name ,,@body))))))

(defmacro defstruct (name &body fields-and-options)
  (apply #'%defstruct-expander name fields-and-options))
