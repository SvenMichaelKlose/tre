(fn sql-clause-insert (&key table (fields nil) (default-values-if-empty? nil))
  (concat-stringtree
      "INSERT INTO " table
      (? (not fields)
         (? default-values-if-empty?
            " DEFAULT VALUES"
            " VALUES()")
         (concat-stringtree
             " ("
             (pad (keys fields) ",")
             ") VALUES ("
             (pad (@ [+ "\"" (escape-string _) "\""]
                     (property-values fields))
                  ",")
             ")"))))
