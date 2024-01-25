(macro *> (&rest x) `(apply ,@x))
(macro ~> (&rest x) `(funcall ,@x))
(macro … (&rest x) `(list ,@x))
;(macro # (&rest x) `(length ,@x))
