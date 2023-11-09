(fn make-php-project (&key outfile title files
                           (files-before-modules nil)
                           (transpiler nil)
                           (section-list-gen nil)
                           (sections-to-update nil))
  (make-project title
    `(,@files-before-modules
      ,@(list+ (+ *modules-path* "/php/")
               '("escape.lisp"
                 "json.lisp"
                 "dump.lisp"))
      (+ *modules-path* "/php-db-mysql/main.lisp")
      ,@(list+ (+ *modules-path* "/sql-clause/")
               `("selection-info.lisp"
                 "create-table.lisp"
                 "delete.lisp"
                 "insert.lisp"
                 "select.lisp"
                 "update.lisp"
                 "utils-querystring.lisp"))
      ,@(list+ (+ *modules-path* "/http-funcall/")
               '("shared/expr2dom.lisp"
                 "php/toplevel.lisp"))
      ,@(list+ (+ *modules-path* "/session/")
               '("php/toplevel.lisp"
                 "api.lisp")))
    :transpiler         (| transpiler
                           (copy-transpiler *php-transpiler*))
    :section-list-gen   section-list-gen
    :sections-to-update sections-to-update
    :emitter            [put-file outfile _]))
