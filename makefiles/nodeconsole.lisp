(= *have-compiler?* t)

(unix-sh-mkdir "compiled" :parents t)

(make-project
  :name   "tré node.js console"
  :emiter [put-file "compiled/nodeconsole.js" _]
  :transpiler
    (aprog1 (copy-transpiler *js-transpiler*)
      (= (transpiler-configuration ! :save-sources?) t))
  :sections
    `((toplevel . ((format t "Welcome to tr&eacute;, revision ~A.~%" *tre-revision*)
                   (eval '(print 'foo))))))

(quit)
