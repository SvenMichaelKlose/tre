(fn schema-type (x)
  (? (string? x)
     x
     x.type))

(fn set-schema-items (value what schema &rest fields)
  (@ (i (| fields (keys schema.properties)) schema)
    (= (ref (ref schema i) what) value)))

(fn make-schema-editable (schema &rest fields)
  (*> #'set-schema-items t "is_editable" schema fields))
