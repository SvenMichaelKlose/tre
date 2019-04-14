(const *fallback-language* 'en)
(const *available-languages* '(en))

(load "tre_modules/l10n/compile-time.lisp")

(make-project "PHP server"
              `("tre_modules/php/json.lisp"
                "tre_modules/php/log-message.lisp"
                "tre_modules/php/milliseconds-since-1970.lisp"
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
                ,@(list+ "tre_modules/http-funcall/"
                         '("shared/expr2dom.lisp"
                           "php/toplevel.lisp"))
                ,@(list+ "tre_modules/session/"
                         '("php/toplevel.lisp"
                           "api.lisp"))
                "server-api.lisp"
                "server/toplevel.lisp")
              :transpiler  *php-transpiler*
              :emitter     [put-file "compiled/server.php" _])
(quit)
