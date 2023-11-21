(fn sql-clause-insert (&key table (fields nil) (default-values-if-empty? nil))
  (flatten
      (list "INSERT INTO " table
            (wben fields
              (list " (" (pad (keys fields) ",") ") VALUES ("
                    (pad (@ [+ "\"" (escape-string _) "\""]
                            (property-values fields))
                         ",")
                    ")")))))
