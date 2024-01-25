(= *have-compiler?* t)

(unix-sh-mkdir "compiled" :parents t)

(make-project
  :title   "tré node.js console"
  :outfile "compiled/nodeconsole.js")
  :files
    `((toplevel . ((format t "Welcome to tr&eacute;, revision ~A.~%" *tre-revision*)
                  (eval '(print 'foo)))))
  :transpiler
    (aprog1 (copy-transpiler *js-transpiler*)
      (= (transpiler-configuration ! :save-sources?) t))

(quit)
