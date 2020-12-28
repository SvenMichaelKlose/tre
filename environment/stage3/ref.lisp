; TODO: Argument expander does not support keyword
; arguments after &REST.
(fn ref (o &rest indexes)
  (dolist (i indexes o)
    (= o (?
           (cons? o)        (assoc-value i o)
           (array? o)       (aref o i)
           (hash-table? o)  (href o i)
           (object? o)      (oref o i)))))

;(defmacro ^ (o &rest indexes)
;  `(ref ,o ,@indexes))
