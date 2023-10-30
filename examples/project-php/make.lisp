(const *fallback-language* :en)
(const *available-languages* '(:en))

(load (+ *modules-path* "l10n/compile-time.lisp"))

(make-project "tré PHP only project"
              `(,@(list+ (+ *modules-path* "php/")
                         `("json.lisp"
                           "dump.lisp"
                           "server-name.lisp"))
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
                (+ *modules-path* "session/php/toplevel.lisp")
                "toplevel.lisp")
              :transpiler  *php-transpiler*
              :emitter     [put-file "compiled/index.php" _])
(quit)
