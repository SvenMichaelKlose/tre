;;;;; tré – Copyright (c) 2005–2009,2011–2014 Sven Michael Klose <pixel@copei.de>

(defun %struct-option-keyword? (x)
  (eq x :constructor))

(defun %struct-make-symbol (name options)
  (!? (assoc-value :constructor options)
      !.
      ($ "MAKE-" name)))

(defun %struct?-symbol (name)
  ($ name "?"))

(defun %struct-field-name (field)
  (? (cons? field)
     field.
     field))

(defun %struct-make-args (fields)
  `(&key ,@(mapcar [let n (%struct-field-name _)
                     `(,n ',n)]
				   fields)))

(defun %struct-make-init (fields g)
  (let index 1
    (mapcar [let argname (%struct-field-name _)
              `(= (aref ,g ,(++! index))
                  (? (eq ,argname ',argname)
                     ,(& (cons? _)
                         (cadr _))
                     ,argname))]
            fields)))

(defun %struct-make (name fields options)
  (with (sym (%struct-make-symbol name options)
		 g (gensym)
         user-init (%struct-make-init fields g)
	     type-init `((= (aref ,g 0) 'struct
                        (aref ,g 1) ',name)))
    `(defun ,sym ,(%struct-make-args fields)
       (let ,g (make-array ,(+ 2 (length fields)))
         ,@(? user-init
	          (append type-init user-init)
	          type-init)
	     ,g))))

(defun %struct-getter-symbol (name field)
  ($ name "-" field))

(defun %struct-single-get (name field index)
  (let sym (%struct-getter-symbol name field)
    `(progn
       (functional ,sym)
       (declare-cps-exception ,sym ,(=-make-symbol sym))
       (defun ,sym (arr)
         (aref arr ,index))
       (defun (= ,sym) (val arr)
         (= (aref arr ,index) val)))))

(defun %struct-getters (name fields)
  (let index 1
    (mapcar [%struct-single-get name (%struct-field-name _) (++! index)] fields)))

(defun struct? (x)
  (& (array? x)
     (eq 'struct (aref x 0))))

(defun %struct? (name)
  (let sym (%struct?-symbol name)
    `(defun ,sym (x)
       (& (array? x)
          (eq 'struct (aref x 0))
          (eq ',name (aref x 1))))))

(defun %struct-sort-fields (fields-and-options)
  (with-queue (fields options)
    (map [? (& (cons? _) (%struct-option-keyword? _.))
	        (enqueue options _)
	        (enqueue fields _)]
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
       (declare-cps-exception ,name)
       ,(%struct-make name flds opts)
       ,(%struct? name)
       ,@(%struct-getters name flds)
       (defmacro ,($ "WITH-" name) (s &body body)
		 `(with-struct ,name ,,s
            ,,@body))
       (defmacro ,($ "DEF-" name) (name args &body body)
	     `(defun ,,name ,,args
            (with-struct ,name ,name
              ,,@body))))))

(defmacro defstruct (name &body fields-and-options)
  (print-definition `(defstruct ,name))
  (apply #'%defstruct-expander name fields-and-options))
