(fn make-json-object (&rest x)
  (!= (%%%make-json-object)
    (@ (i (group x 2) !)
      (= (slot-value ! (? (symbol? i.)
                          (downcase (symbol-name i.))
                          i.))
         .i.))))

(defmacro %%make-json-object (&rest props)
  `(%%%make-json-object ,@(mapcan [list (? (symbol? _.)
                                      (list-string (camel-notation (string-list (symbol-name _.))))
                                      _.)
                                   ._.]
                             (group props 2))))
