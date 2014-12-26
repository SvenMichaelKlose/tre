; tré – Copyright (c) 2005–2009,2011–2014 Sven Michael Klose <pixel@hugbox.org>

(defun %struct-option-keyword? (x)
  (eq x :constructor))

(defun %struct-constructor-name (name options)
  (!? (assoc-value :constructor options)
      !.
      ($ "MAKE-" name)))

(defun %struct?-symbol (name)
  ($ name "?"))

(defun %struct-field-name (field)
  (? (cons? field)
     field.
     field))

(defun %struct-constructor-args (fields)
  `(&key ,@(filter [let n (%struct-field-name _)
                     `(,n ',n)]
				   fields)))

(defun %struct-init (fields g)
  (let index 1
    (filter [let argname (%struct-field-name _)
              `(= (aref ,g ,(++! index))
                  (? (eq ,argname ',argname)
                     ,(& (cons? _)
                         ._.)
                     ,argname))]
            fields)))

(defun %struct-make (name fields options)
  (with (fname      (%struct-constructor-name name options)
		 g          (gensym)
         user-init  (%struct-init fields g)
	     type-init  `((= (aref ,g 0) 'struct
                         (aref ,g 1) ',name)))
    `(defun ,fname ,(%struct-constructor-args fields)
       (let ,g (make-array ,(+ 2 (length fields)))
         ,@(? user-init
	          (+ type-init user-init)
	          type-init)
	     ,g))))

(defun %struct-accessor-name (name field)
  ($ name "-" field))

(defun %struct-slot-accessors (name field index)
  (let sym (%struct-accessor-name name field)
    `(progn
       (functional ,sym)
       (declare-cps-exception ,sym ,(=-make-symbol sym))
       (defun ,sym (arr)
         (aref arr ,index))
       (defun (= ,sym) (val arr)
         (= (aref arr ,index) val)))))

(defun %struct-accessors (name fields)
  (let index 1
    (filter [%struct-slot-accessors name (%struct-field-name _) (++! index)]
            fields)))

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
    (map [? (& (cons? _)
               (%struct-option-keyword? _.))
	        (enqueue options _)
	        (enqueue fields _)]
	     fields-and-options)
    (values (queue-list fields)
            (queue-list options))))

(defvar *struct-defs*)

(defun %struct-add-def (name def)
  (acons! name def *struct-defs*))

(defun %struct-def (name)
  (assoc-value name *struct-defs*))

(defun %struct-fields (name)
  (carlist (%struct-def name)))

(defun %defstruct-expander (name &rest fields-and-options)
  (with ((fields options) (%struct-sort-fields fields-and-options))
    (%struct-add-def name fields)
    `(progn
       (declare-cps-exception ,name)
       ,(%struct-make name fields options)
       ,(%struct? name)
       ,@(%struct-accessors name fields)
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
