(fn make-object (&rest x)
  (!= (%%%make-object)
    (@ (i (group x 2) !)
      (= (slot-value ! (? (symbol? i.)
                          (downcase (symbol-name i.))
                          i.))
         .i.))))

(defmacro %%make-object (&rest props)
  `(%%%make-object ,@(mapcan [list (list-string (camel-notation (string-list (? (symbol? _.)
                                                                                (symbol-name _.)
                                                                                _.))))
                                   ._.]
                             (group props 2))))
