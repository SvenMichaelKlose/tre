(const *sql-max-dump-length* 4096)

(defclass db-mysql (&key host name user password)
  (= _name name)
  (= _conn (new mysqli host user password))
  (= _column-names (make-hash-table))
  (= _logging? nil)
  (_conn.set_charset "utf8mb4")
  (_conn.select_db _name)
  this)

(defmember db-mysql
    _name
    _conn
    _column-names
    _logging?)

(defmethod db-mysql set-logging (x)
  (= _logging? x))

(defmethod db-mysql last-insert-row-i-d ()
  _conn.insert_id)

(defmethod db-mysql last-error ()
  (alet _conn.error
    (unless (empty-string? !)
      !)))

(defmethod db-mysql last-error-string ()
  _conn.error)

(defmethod db-mysql _handle-error (method-name)
  (when (last-error)
    (error (+ "Error: PHP-SQL." (upcase method-name) ": " (last-error-string)))))

(defmethod db-mysql _log (statement)
  (& _logging?
     (dump (+ "SQL: " (? (< *sql-max-dump-length* (length statement))
                         (subseq statement (- (length statement) *sql-max-dump-length*))
                         statement)))))

(defmethod db-mysql exec-list (statement)
  (_log statement)
  (with (res (_conn.query statement)
         ret (make-queue))
    (_handle-error "exec-list")
    (unless (is_bool res)
      (awhile (res.fetch_row)
              (queue-list ret)
        (enqueue ret (array-list !))))))

(defmethod db-mysql exec (statement)
  (_log statement)
  (with (res (_conn.query statement)
         ret (make-queue))
    (_handle-error "exec")
    (unless (is_bool res)
      (awhile (res.fetch_object)
              (queue-list ret)
        (enqueue ret !)))))

(defmethod db-mysql exec-simple (statement)
  (_log statement)
  (_conn.query statement))

(defmethod db-mysql column-names (table-name)
  (| (href _column-names table-name)
     (= (href _column-names table-name) (carlist (exec-list (+ "SHOW COLUMNS FROM " table-name))))))

(defmethod db-mysql add-column (table-name column-name)
  (exec (+ "ALTER TABLE " table-name " ADD COLUMN " column-name)))

(defmethod db-mysql table? (name)
  (prog1
    (== 1 (caar (exec-list (+ "SELECT COUNT(1) FROM information_schema.tables "
                              " WHERE table_schema='" _name "' AND table_name='" name "'"))))
    (_handle-error "table?")))

(defmethod db-mysql begin-transaction ()
  (exec-simple "START TRANSACTION"))

(defmethod db-mysql commit ()
  (exec-simple "COMMIT"))

(defmethod db-mysql rollback ()
  (exec-simple "ROLLBACK"))

(defmethod db-mysql close ()
  (_conn.close)
  (clr _conn))

;(defmethod db-mysql create-db (name)
;  (mysql_create_db name)
;  (= _name name))

;(defmethod db-mysql remove ()
;  (close)
;  (mysql_drop_db _name))

;(defmethod db-mysql escape (x)
;  (mysqli_real_escape_string x))

(finalize-class db-mysql)
