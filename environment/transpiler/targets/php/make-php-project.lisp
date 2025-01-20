(fn make-php-project (&key outfile title files
                           (files-before-modules nil) (transpiler nil))
  (make-project title
    `(,@files-before-modules
      ,@(list+ (+ *modules-path* "/php/")
               '("escape.lisp"
                 "json.lisp"
                 "dump.lisp"))
      ,(+ *modules-path* "/php-db-mysql/main.lisp")
      ,(+ *modules-path* "/php-http-request/main.lisp")
      ,@(list+ (+ *modules-path* "/http-funcall/")
               '("shared/expr2props.lisp"
                 "php/toplevel.lisp"))
      ,@(list+ (+ *modules-path* "/session/")
               '("php/toplevel.lisp"
                 "api.lisp"))
      ,@files)
    :transpiler (| transpiler (copy-transpiler *php-transpiler*))
    :emitter    [put-file outfile _]))
