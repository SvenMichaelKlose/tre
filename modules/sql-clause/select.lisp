(fn alist-assignments (x &key (padding ", ") (quote-char #\"))
  (*> #'+
      (pad (@ #'((k v)
                  (+ k "=" (literal-string (string v) quote-char quote-char)))
              (@ #'downcase (@ #'symbol-name (carlist x)))
              (cdrlist x))
           padding)))

(fn sql-clause-where (alst)
  (!? alst
      (+ " WHERE "
         (? (string? !)
            !
            (alist-assignments ! :padding " AND ")))))

(def-selection-info sql-clause-select (selection-info)
  (*> #'string-concat
      `("SELECT " ,@(!? fields
                        (pad (@ #'downcase (@ #'symbol-name !)) ",")
                        (… "*"))
        " FROM " ,table
        ,(sql-clause-where where)
        ,(!? order-by  (+ " ORDER BY " !))
        ,(!? direction (+ " " !))
        ,(!? limit     (+ " LIMIT " !))
        ,(!? (& offset
                (not (== 0 offset)))
             (+ " OFFSET " !)))))
