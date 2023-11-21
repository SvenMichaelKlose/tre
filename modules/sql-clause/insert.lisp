(fn sql-clause-insert (&key table (fields nil) (default-values-if-empty? nil))
  (flatten
      "INSERT INTO " table
      (? (not fields)
         (? default-values-if-empty?
            " DEFAULT VALUES"
            " VALUES()")
         (flatten
             " ("
             (pad (keys fields) ",")
             ") VALUES ("
             (pad (@ [+ "\"" (escape-string _) "\""]
                     (property-values fields))
                  ",")
             ")"))))
