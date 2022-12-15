(fn sql-clause-delete (&key table where)
  (+ "DELETE FROM " table
     (sql-clause-where where)))
