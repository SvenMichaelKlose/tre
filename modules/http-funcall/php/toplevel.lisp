(var *server-commands* (make-hash-table))

(defmacro declare-server-command (name args)
  (print-definition `(declare-server-command ,name ,args))
  (with-gensym g
    `(progn
       (fn ,g ,args
         (,(compiled-function-name name) ,@(argument-expand-names 'declare-server-command-implementation args)))
       (= (href *server-commands* ',name) #',g))))

(fn serve-http-funcall ()
  (header "Content-Type: application/json")
  (!= (props2expr (json-decode (%aref *_post* "q")))
    (%= nil (echo (json-encode (expr2props (*> (href *server-commands* !.) .!)))))))
