(fn sql-clause-create-table (table-definition &key (auto-increment nil) (have-types? nil))
  (with (name  table-definition.
         cols  .table-definition.)
    (apply #'+ `("CREATE TABLE " ,name " ("
                 ,@(pad (@ [+ _. " " (? have-types? ._. "")]
                           `(,@(& auto-increment
                                  (list (list "id" (+ "INTEGER PRIMARY KEY " (| auto-increment "")))))
                             ,@cols))
                        ",")
                 ")"))))
