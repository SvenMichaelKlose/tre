(= *allow-redefinitions?* t)
(= *have-compiler?* t)

(unix-sh-mkdir "compiled" :parents t)
(make-project "tré node.js console"
              `((toplevel . ((format t "Welcome to tr&eacute;, revision ~A.~%" *tre-revision*)
                             (eval '(print 'foo)))))
              :transpiler  (aprog1 (copy-transpiler *js-transpiler*)
                             (= (transpiler-configuration ! :save-sources?) t))
              :emitter     [(format t "Writing to 'compiled/nodeconsole.js'…~F")
                            (put-file "compiled/nodeconsole.js" _)
                            (terpri)])
(quit)
