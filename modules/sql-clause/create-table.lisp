(fn sql-clause-create-table (table-definition &key (auto-increment nil) (have-types? nil))
  (with (name  table-definition.
         cols  .table-definition.)
    (*> #'+ `("CREATE TABLE " ,name " ("
              ,@(pad (@ [+ _. " " (? have-types? ._. "")]
                        `(,@(& auto-increment
                               (… (… "id" (+ "INTEGER PRIMARY KEY " (| auto-increment "")))))
                          ,@cols))
                     ",")
              ")"))))
