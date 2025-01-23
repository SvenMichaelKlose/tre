(var *autoform-widgets* nil)

(defmacro def-autoform-widget (args predicate &body body)
  `(push {:predicate ,predicate
          :maker     #'(,args ,@body)}
         *autoform-widgets*))

(defmacro def-editable-autoform-widget (args predicate &body body)
  `(def-autoform-widget ,args ,predicate ,@body))

(macro autoform-fn (name (schema store &optional key) &rest body)
  `(progn
     (fn ,name (props)
       (with (,schema   props.schema
              ,store    props.store
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
        (~> !.key !.store)
      (@ (widget !.widgets)
        (when (~> widget.predicate !.schema)
          (return (~> widget.maker
                      !.store !.key !.schema
                      (when !.store
                        (!.store.value !.key)))))))))

(finalize-class autoform-field)
(declare-lml-component autoform-field)


(autoform-fn autoform-array (schema store)
  `(table :class "autoform-array"
     ,@(@ [`(autoform-preview :schema   ,schema.items
                              :store    ,_
                              :widgets  ,widgets)]
          store.data)))

(autoform-fn autoform-property (schema store)
  (!= (aref schema.properties props.key)
    `(label :class "autoform-property"
       (span ,(| (i18n !.title)
                 props.key))
       (autoform-field :key      ,props.key
                       :schema   ,!
                       :store    ,store
                       :widgets  ,widgets))))

(autoform-fn autoform-object (schema store)
  `(div :class "autoform-object"
     ,@(@ [`(autoform-property :key      ,_
                               :schema   ,schema
                               :store    ,store
                               :widgets  ,widgets)]
          (keys schema.properties))))

(autoform-fn autoform (schema store)
  "Dispatch to 'AUTOFORM-<basic JSON type>'."
  `(,(? (in? (schema-type schema) "array" "object")
        ($ 'autoform- (upcase (schema-type schema)))
        'autoform-field)
     :schema   ,schema
     :store    ,store
     :widgets  ,(| widgets *autoform-widgets*)))
