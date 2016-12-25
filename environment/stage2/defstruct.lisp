(defun %struct-option-keyword? (x)
  (in? x :constructor :global))

(defun %struct-constructor-name (name options)
  (!? (assoc-value :constructor options)
      !.
      ($ "MAKE-" name)))

(defun %struct-predicate-name (name)
  ($ name "?"))

(defun %struct-field-name (field)
  (? (cons? field)
     field.
     field))

(defun %struct-field-options (field)
  (& (cons? field)
     ..field))

(defun %struct-constructor-args (fields)
  `(&key ,@(@ [let n (%struct-field-name _)
                `(,n ',n)]
              fields)))

(defun %struct-init (fields g)
  (let index 1
    (@ [let argname (%struct-field-name _)
         `(= (aref ,g ,(++! index))
             (? (eq ,argname ',argname)
                 ,(& (cons? _)
                     ._.)
                 ,argname))]
       fields)))

(defun %struct-constructor (name fields options)
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

(defun %struct-accessor-name (name field-name)
  ($ name "-" field-name))

(defun %struct-slot-accessors (name field index options)
  (with (fname  (%struct-field-name field)
         aname  (%struct-accessor-name name fname))
    `{(functional ,aname)
      (defun ,aname (arr)
        (aref arr ,index))
      (defun (= ,aname) (val arr)
        (= (aref arr ,index) val))
      ,@(!? (& (not (member :not-global (%struct-field-options field)))
               (assoc :global options))
            `((defun ,fname ()
                (aref ,.!. ,index))
              (defun (= ,fname) (val)
                (= (aref ,.!. ,index) val))))}))

(defun %struct-accessors (name fields options)
  (let index 1
    (@ [%struct-slot-accessors name _ (++! index) options]
       fields)))

(defun struct-predicate (x)
  (& (array? x)
     (eq 'struct (aref x 0))))

(defun %struct-predicate (name)
  `(defun ,(%struct-predicate-name name) (x)
     (& (array? x)
        (eq 'struct (aref x 0))
        (eq ',name (aref x 1)))))

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
    `{,(%struct-constructor name fields options)
      ,(%struct-predicate name)
      ,@(%struct-accessors name fields options)
      (defmacro ,($ "WITH-" name) (s &body body)
	    `(with-struct ,name ,,s
           ,,@body))
      (defmacro ,($ "DEF-" name) (name args &body body)
	    `(defun ,,name ,,args
           (with-struct ,name ,name
             ,,@body)))}))

(defmacro defstruct (name &body fields-and-options)
  (print-definition `(defstruct ,name))
  (apply #'%defstruct-expander name fields-and-options))
