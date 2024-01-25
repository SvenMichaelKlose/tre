(var *autoform-widgets* nil)

(defmacro def-autoform-widget (args predicate &body body)
  `(+! *autoform-widgets* (… {:predicate ,predicate
                              :maker     #'(,args ,@body)})))


(defclass (autoform-field lml-component) (init-props)
  (super init-props))

(defmethod autoform-field render ()
  (!= props
    (?
      (function? !.key)
        (~> !.key !.data)
      (@ (widget *autoform-widgets*)
        (when (~> widget.predicate !.schema)
          (return (~> widget.maker
                      !.schema !.key !.data
                      (aref !.data !.key))))))))

(finalize-class autoform-field)
(declare-lml-component autoform-field)


(macro autoform-fn (name (schema data &optional key) &rest body)
  `(progn
     (fn ,name (props)
       (with (,schema props.schema
              ,data   props.data
              ,key    props.key)
         ,@body))
     (declare-lml-component ,name)))

(autoform-fn autoform-preview-object (schema data)
  `(tr
     ,@(@ [`(td (autoform-field :key     ,_
                                :schema  ,(aref schema.properties _)
                                :data    ,(aref data _)))]
          props.fields)))

(autoform-fn autoform-array (schema data)
  `(table :class "autoform-array"
     ,@(@ [`(autoform-preview :schema  ,schema.items
                              :data    ,_)]
          data)))

(autoform-fn autoform-property (schema data)
  (!= (aref schema.properties props.key)
    `(label :class "autoform-property"
       (span ,(| !.title props.key))
       (autoform-field :key     ,props.key
                       :schema  ,!
                       :data    ,data
                       :widgets ,*autoform-widgets*))))

(autoform-fn autoform-object (schema data)
  `(div :class "autoform-object"
     ,@(@ [`(autoform-property :schema ,schema :data ,data :key ,_)]
          props.fields)))

(autoform-fn autoform (schema data)
  `(,(? (in? (schema-type schema) "array" "object")
        ($ 'autoform- (upcase (schema-type schema)))
        'autoform-field)
     :schema ,schema
     :data   ,data))
