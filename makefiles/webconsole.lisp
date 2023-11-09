(load (+ *modules-path* "/js/make-js-project.lisp"))

(= *allow-redefinitions?* t)
(= *have-compiler?* t)

(unix-sh-mkdir "compiled" :parents t)
(make-js-project
  :title
    "tré web console"
  :outfile
    "compiled/webconsole.html"
  :files
    `((toplevel . ((document-extend)
                   (format t "Welcome to tré, revision ~A.~%" *tre-revision*))))
  :transpiler
    (aprog1 (copy-transpiler *js-transpiler*)
      (= (transpiler-configuration ! :save-sources?) t)))
(quit)
