(fn sql-clause-where (alst)
  (!? alst
      (+ " WHERE "
         (? (string? !)
            !
            (alist-assignments ! :padding " AND ")))))

(def-selection-info sql-clause-select (selection-info)
  (apply #'string-concat
         `("SELECT " ,@(!? fields
                           (pad (@ #'downcase (@ #'symbol-name !)) ",")
                           (list "*"))
           " FROM " ,table
           ,(sql-clause-where where)
           ,(!? order-by  (+ " ORDER BY " !))
           ,(!? direction (+ " " !))
           ,(!? limit     (+ " LIMIT " !))
           ,(!? (& offset
                   (not (== 0 offset)))
                (+ " OFFSET " !)))))
