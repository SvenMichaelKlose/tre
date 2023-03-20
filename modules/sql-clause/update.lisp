(fn sql-clause-update (&key table fields (where nil))
  (+ "UPDATE " table
     " SET " (apply #'+ (pad (@ [sql= _ (slot-value fields _)]
                                (keys fields))
                             ","))
     (sql-clause-where where)))