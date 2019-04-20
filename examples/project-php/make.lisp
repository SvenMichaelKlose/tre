(const *fallback-language* :en)
(const *available-languages* '(:en))

(load "tre_modules/l10n/compile-time.lisp")

(make-project "tré PHP only project"
              `(,@(list+ "tre_modules/php/"
                         `("json.lisp"
                           "log-message.lisp"
                           "server-name.lisp"))
                "tre_modules/php-db-mysql/main.lisp"
                "tre_modules/php-http-request/main.lisp"
                ,@(list+ "tre_modules/l10n/"
                         `("lang.lisp"
                           "l10n.lisp"))
                ,@(list+ "tre_modules/sql-clause/"
                         `("selection-info.lisp"
                           "create-table.lisp"
                           "delete.lisp"
                           "insert.lisp"
                           "select.lisp"
                           "update.lisp"
                           "utils-querystring.lisp"))
                "tre_modules/session/php/toplevel.lisp"
                "toplevel.lisp")
              :transpiler  *php-transpiler*
              :emitter     [put-file "compiled/index.php" _])
(quit)
