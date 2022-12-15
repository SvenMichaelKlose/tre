(var *autoform-widgets* nil)

(defmacro def-autoform-widget (args predicate &body body)
  `(= *autoform-widgets* (append *autoform-widgets*
                                 (list {:predicate  ,predicate
                                        :maker      #'(,args ,@body)}))))

(defmacro def-editable-autoform-widget (args predicate &body body)
  `(def-autoform-widget ,args [& _.is_editable (funcall ,predicate _)] ,@body))


; Editables

(def-editable-autoform-widget (store name schema v) [eql _.type "selection"]
  (with (has-default?  (defined? schema.default)
         av            (autoform-value schema v))
    `(select :name       ,name
             :on-change  ,[store.write (make-object name ((_.element).get ":checked").value)]
             ,@(!? schema.is_required `(:required "yes"))
       ,@(@ [`(option :value ,_
                      ,@(? (eql _ av)
                           `(:selected "yes"))
                ,(aref schema.options _))]
            (property-names schema.options)))))

(fn autoform-pattern-required (schema)
  `(,@(!? schema.pattern      `(:pattern ,!))
    ,@(!? schema.is_required  `(:required "yes"))))

(fn autoform-value (schema v)
  (| v
     (& (defined? schema.default)
        schema.default)
     ""))

(fn make-autoform-input-element (typ store name schema v)
  `(input :type  ,typ
          :name  ,name
          ,@(!? schema.size `(:size ,!))
          ,@(autoform-pattern-required schema)
          :on-change  ,[store.write (make-object name _.target.value)]
          :value      ,(autoform-value schema v)))

(def-editable-autoform-widget (store name schema v) [in? _.type "string" "password" "email"]
  (make-autoform-input-element (? (eql schema.type "string")
                                  "text"
                                  schema.type)
                               store name schema v))

(def-editable-autoform-widget (store name schema v) [eql _.type "boolean"]
  (let av (? (defined? (slot-value store.data name))
             v
             (!= (autoform-value schema v)
               (store.write (make-object name !))))
    `(input :type      "checkbox"
            :name      ,name
            :on-click  ,[store.write (make-object name _.target.checked)]
            ,@(& av '(:checked "1")))))

(def-editable-autoform-widget (store name schema v) [eql _.type "text"]
  `(textarea :name  ,name
             ,@(autoform-pattern-required schema)
             :on-change  ,[store.write (make-object name _.target.value)]
     ,(autoform-value schema v)))


; Non-editables

(def-autoform-widget (store name schema v) [eql _.type "text"]
  `(pre ,(autoform-value schema v)))

(def-autoform-widget (store name schema v) [eql _.type "selection"]
  (aref schema.options v))

(def-autoform-widget (store name schema v) [identity t]
  (autoform-value schema v))


(fn set-schema-items (value what schema &rest fields)
  (@ (i (| fields (property-names schema)) schema)
    (= (aref (aref schema i) what) value)))

(fn make-schema-editable (schema &rest fields)
  (apply #'set-schema-items t "is_editable" schema fields))
