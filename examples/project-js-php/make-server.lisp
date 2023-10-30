(const *fallback-language* :en)
(const *available-languages* '(:en))

(load (+ *modules-path* "l10n/compile-time.lisp"))

(make-project "PHP server"
              `(
                ,@(list+ (+ *modules-path* "php/")
                         `("json.lisp"
                           "dump.lisp"))
                (+ *modules-path* "php-db-mysql/main.lisp")
                (+ *modules-path* "php-http-request/main.lisp")
                ,@(list+ (+ *modules-path* "l10n/")
                         `("lang.lisp"
                           "l10n.lisp"))
                ,@(list+ (+ *modules-path* "sql-clause/")
                         `("selection-info.lisp"
                           "create-table.lisp"
                           "delete.lisp"
                           "insert.lisp"
                           "select.lisp"
                           "update.lisp"
                           "utils-querystring.lisp"))
                ,@(list+ (+ *modules-path* "http-funcall/")
                         '("shared/expr2dom.lisp"
                           "php/toplevel.lisp"))
                ,@(list+ (+ *modules-path* "session/")
                         '("php/toplevel.lisp"
                           "api.lisp"))
                "server-api.lisp"
                "server/toplevel.lisp")
              :transpiler  *php-transpiler*
              :emitter     [put-file "compiled/server.php" _])
(quit)
