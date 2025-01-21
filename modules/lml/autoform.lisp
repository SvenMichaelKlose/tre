(var *autoform-widgets* nil)

(defmacro def-autoform-widget (args predicate &body body)
  `(push {:predicate ,predicate
          :maker     #'(,args ,@body)}
         *autoform-widgets*))

(defmacro def-editable-autoform-widget (args predicate &body body)
  `(push {:predicate ,predicate
          :maker     #'(,args ,@body)}
         *autoform-widgets*))

(macro autoform-fn (name (schema data &optional key) &rest body)
  `(progn
     (fn ,name (props)
       (with (,schema   props.schema
              ,data     props.data
              ,key      props.key
              widgets   props.widgets)
         ,@body))
     (declare-lml-component ,name)))


(defclass (autoform-field lml-component) (init-props)
  (super init-props))

(defmethod autoform-field render ()
  (!= props
    (?
      (function? !.key)
        (~> !.key !.data)
      (@ (widget !.widgets)
        (when (~> widget.predicate !.schema)
          (return (~> widget.maker
                      !.data !.key !.schema
                      (when !.data
                        (aref !.data !.key)))))))))

(finalize-class autoform-field)
(declare-lml-component autoform-field)


(autoform-fn autoform-preview-object (schema data)
  `(tr
     ,@(@ [`(td (autoform-field :key      ,_
                                :schema   ,(aref schema.properties _)
                                :data     ,(aref data _)
                                :widgets  ,widgets))]
          props.fields)))

(autoform-fn autoform-array (schema data)
  `(table :class "autoform-array"
     ,@(@ [`(autoform-preview :schema   ,schema.items
                              :data     ,_
                              :widgets  ,widgets)]
          data)))

(fn autoform-i18n (x)
  (? (json-object? x)
     x.en
     x))

(autoform-fn autoform-property (schema data)
  (!= (aref schema.properties props.key)
    `(label :class "autoform-property"
       (span ,(| (autoform-i18n !.title) props.key))
       (autoform-field :key      ,props.key
                       :schema   ,!
                       :data     ,data
                       :widgets  ,widgets))))

(autoform-fn autoform-object (schema data)
  `(div :class "autoform-object"
     ,@(@ [`(autoform-property :key      ,_
                               :schema   ,schema
                               :data     ,data
                               :widgets  ,widgets)]
          (keys schema.properties))))

(autoform-fn autoform (schema data)
  "Dispatch to 'AUTOFORM-<basic JSON type>'."
  `(,(? (in? (schema-type schema) "array" "object")
        ($ 'autoform- (upcase (schema-type schema)))
        'autoform-field)
     :schema   ,schema
     :data     ,data
     :widgets  ,(| widgets *autoform-widgets*)))
