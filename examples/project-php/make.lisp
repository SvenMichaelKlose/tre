(const *fallback-language* 'en)
(const *available-languages* '(en))

(make-project "tré PHP only project"
              `(
                "tre_modules/php/json.lisp"
                "tre_modules/php/log-message.lisp"
                "tre_modules/php/milliseconds-since-1970.lisp"
                "tre_modules/php/server-name.lisp"
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
                "toplevel.lisp")
              :transpiler  *php-transpiler*
              :emitter     [put-file "compiled/index.php" _])
(quit)
