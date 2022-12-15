(defclass (autoform lml-component) (init-props)
  (super (merge-props {:widgets *autoform-widgets*} init-props))
  this)

(defmethod autoform render ()
  (error "Class AUTOFORM cannot be used alone. Use derived classes like AUTOFORM-RECORD or AUTOFORM-LIST."))

(finalize-class autoform)
(declare-lml-component autoform)


(defclass (autoform-field autoform) (init-props)
  (super init-props)
  this)

(defmethod autoform-field _value ()
  (let v (props.store.value props.field)
    (!? props.schema-item.printer
        (funcall ! v)
        v)))

(defmethod autoform-field _render-typed-field ()
  (@ (widget props.widgets)
    (& (funcall widget.predicate props.schema-item)
       (return (funcall widget.maker props.store props.field props.schema-item (_value))))))

(defmethod autoform-field render ()
  ($$ (!= props.field
        (?
          (function? !)  (funcall ! props.store.data)
          (string? !)    (_render-typed-field)
          !))))

(finalize-class autoform-field)
(declare-lml-component autoform-field)


(fn field-class-name (x)
  (+ "field-" x))

(fn autoform-list (props)
  ($$ `(tr ,@(@ [`(td ,@(& (string? _) `(:class ,(field-class-name _)))
                    (autoform-field :schema-item  ,(aref props.schema _)
                                    :field        ,_
                                    :store        ,props.store))]
                props.fields))))

(declare-lml-component autoform-list)


(fn autoform-record (props)
  (let render-label [!? (aref (aref props.schema _) "title")
                        (? (object? !)
                           (aref ! (downcase (symbol-name *language*)))
                           !)]
    ($$ `(div :class "autoform autoform-record"
           ,@(@ [`(label ,@(& (string? _) `(:class ,(field-class-name _)))
                    (span
                      ,(? (string? _)
                          (render-label _)))
                    (autoform-field :schema-item  ,(aref props.schema _)
                                    :field        ,_
                                    :store        ,props.store))]
                props.fields)))))

(declare-lml-component autoform-record)
