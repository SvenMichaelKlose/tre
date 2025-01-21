(fn autoform-value (schema v)
  (| v
     (awhen schema
       !.default)
     ""))

(def-autoform-widget (store name schema v)
                     [identity t]
  `(pre :class "autoform-field-generic"
     ,(autoform-value schema v)))
