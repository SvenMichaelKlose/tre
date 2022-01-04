(fn sql-clause-update (&key table fields (where nil))
  (+ "UPDATE " table
     " SET " (apply #'+ (pad (@ [sql= _ (slot-value fields _)]
                                (property-names fields))
                             ","))
     (sql-clause-where where)))
