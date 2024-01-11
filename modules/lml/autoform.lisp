(defclass (autoform lml-component) (init-props)
  (super init-props)
  this)

(finalize-class autoform)
(declare-lml-component autoform)


(defclass (autoform-field autoform) (init-props)
  (super init-props)
  this)

(defmethod autoform-field render ()
  (!= props
    (?
      (function? !.key)
        (funcall !.key !.data)
      (@ (widget *autoform-widgets*)
        (when (funcall widget.predicate !.schema)
          (return (funcall widget.maker
                           !.schema !.key !.data
                           (aref !.data !.key))))))))

(finalize-class autoform-field)
(declare-lml-component autoform-field)


(macro autoform-fn (name (schema data) &rest body)
  `(progn
     (fn ,name (props)
       (with (,schema props.schema
              ,data   props.data)
         ,@body))
     (declare-lml-component ,name)))

(autoform-fn autoform-preview-object (schema data)
  `(tr
     ,@(@ [`(td (autoform-field :key     ,_
                                :schema  ,(aref schema.properties _)
                                :data    ,(aref data _)))]
          props.fields)))

(autoform-fn autoform-preview (schema data)
  `(,(make-symbol (+ "AUTOFORM-PREVIEW- " (upcase schema.type)))
     :schema ,schema
     :data  ,data))

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
