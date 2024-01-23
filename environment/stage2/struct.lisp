(fn %struct-option-keyword? (x)
  (in? x :constructor :global))

(fn %struct-constructor-name (name options)
  (!? (assoc-value :constructor options)
      !.
      ($ "MAKE-" name)))

(fn %struct-predicate-name (name)
  ($ name "?"))

(fn %struct-field-name (field)
  (? (cons? field)
     field.
     field))

(fn %struct-field-options (field)
  (& (cons? field)
     ..field))

(fn %struct-constructor-args (fields)
  `(&key ,@(@ [let n (%struct-field-name _)
                `(,n ',n)]
              fields)))

(fn %struct-init (fields g)
  (let index 1
    (@ [let argname (%struct-field-name _)
         `(= (aref ,g ,(++! index))
             (? (eq ,argname ',argname)
                 ,(& (cons? _)
                     ._.)
                 ,argname))]
       fields)))

(fn %struct-constructor (name fields options)
  (with (fname      (%struct-constructor-name name options)
         g          (gensym)
         user-init  (%struct-init fields g)
         type-init  `((= (aref ,g 0) 'struct
                         (aref ,g 1) ',name)))
    `(fn ,fname ,(%struct-constructor-args fields)
       (let ,g (make-array ,(+ 2 (length fields)))
         ,@(? user-init
              (+ type-init user-init)
              type-init)
         ,g))))

(fn %struct-accessor-name (name field-name)
  ($ name "-" field-name))

(fn %struct-slot-accessors (name field index options)
  (with (fname  (%struct-field-name field)
         aname  (%struct-accessor-name name fname))
    `(progn
       (functional ,aname)
       (fn ,aname (arr)
         (aref arr ,index))
       (fn (= ,aname) (val arr)
         (= (aref arr ,index) val))
       ,@(!? (& (not (member :not-global (%struct-field-options field)))
                (assoc :global options))
             `((fn ,fname ()
                 (aref ,.!. ,index))
               (fn (= ,fname) (val)
                 (= (aref ,.!. ,index) val)))))))

(fn %struct-accessors (name fields options)
  (let index 1
    (@ [%struct-slot-accessors name _ (++! index) options]
       fields)))

(fn struct-predicate (x)
  (& (array? x)
     (eq 'struct (aref x 0))))

(fn %struct-predicate (name)
  `(fn ,(%struct-predicate-name name) (x)
     (& (array? x)
        (eq 'struct (aref x 0))
        (eq ',name (aref x 1)))))

(fn %struct-sort-fields (fields-and-options)
  (with-queue (fields options)
    (@ [? (& (cons? _)
             (%struct-option-keyword? _.))
          (enqueue options _)
          (enqueue fields _)]
       fields-and-options)
    (values (queue-list fields)
            (queue-list options))))

(var *struct-defs*)

(fn %struct-add-def (name def)
  (acons! name def *struct-defs*))

(fn %struct-def (name)
  (assoc-value name *struct-defs*))

(fn %struct-fields (name)
  (carlist (%struct-def name)))

(defmacro defstruct (name &body fields-and-options)
  (print-definition `(defstruct ,name))
  (with ((fields options) (%struct-sort-fields fields-and-options))
    (%struct-add-def name fields)
    `(progn
       ,(%struct-constructor name fields options)
       ,(%struct-predicate name)
       ,@(%struct-accessors name fields options)
       (defmacro ,($ "WITH-" name) (s &body body)
         `(with-struct ,name ,,s
            ,,@body))
       (defmacro ,($ "DEF-" name) (name args &body body)
         `(fn ,,name ,,args
            (with-struct ,name ,name
              ,,@body))))))
(defmacro with-struct (typ strct &body body)
  (!= (assoc-value typ *struct-defs*)
    (with-gensym g
      `(let ,g ,strct
         (#'((,typ ,@(@ #'%struct-field-name !))
             ,@(@ [%struct-field-name _] !)
             ,@body)
          ,g ,@(@ [`(,(%struct-accessor-name typ (%struct-field-name _)) ,g)] !))))))
