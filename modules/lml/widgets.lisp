(fn autoform-value (schema v)
  (| v schema.default ""))

(def-autoform-widget (store name schema v)
                     [identity t]
  `(pre :class "autoform-field-generic"
     ,(autoform-value schema v)))

(fn set-schema-items (value what schema &rest fields)
  (@ (i (| fields (keys schema.properties)) schema)
    (= (ref (ref schema i) what) value)))

(fn make-schema-editable (schema &rest fields)
  (apply #'set-schema-items t "is_editable" schema fields))
