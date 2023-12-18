(defclass (autoform lml-component) (init-props)
  (super (merge {:widgets *autoform-widgets*} init-props))
  this)

(finalize-class autoform)
(declare-lml-component autoform)


(defclass (autoform-field autoform) (init-props)
  (super init-props)
  this)

(defmethod autoform-field _render-widget ()
  (!= props
    (@ (widget !.widgets)
      (& (funcall widget.predicate !.schema-item)
         (return (funcall widget.maker
                          !.store !.key !.schema-item
                          (!.store.value !.key)))))))

(defmethod autoform-field render ()
  (!= props.key
    ($$
      (?
        (function? !)
          (funcall ! props.store.data)
        (string? !)
          (_render-widget)
        !))))

(finalize-class autoform-field)
(declare-lml-component autoform-field)


(fn autoform-list (props)
  ($$
    `(tr
       ,@(@ [`(td
                (autoform-field
                    :schema-item  ,props.schema.items
                    :key          ,_
                    :store        ,props.store))]
            props.fields))))

(declare-lml-component autoform-list)


(fn autoform-record (props)
  ($$
    `(div
       ,@(@ [!= (ref props.schema.properties _)
              `(label
                 (span
                   ,(| !.title _))
                 (autoform-field
                     :schema-item  ,!
                     :key          ,_
                     :store        ,props.store))]
            props.fields))))

(declare-lml-component autoform-record)
