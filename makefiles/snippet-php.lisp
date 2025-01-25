(unix-sh-mkdir "compiled" :parents t)
(make-project
  :name
    "Compile tré Lisp expression to PHP"
  :sections
    `((toplevel . ((print 'add-your-test-here))))
  :transpiler
    (aprog1 (copy-transpiler *php-transpiler*)
      (= (transpiler-configuration ! :save-sources?) nil))
  :emitter
    [(format t "Writing to 'compiled/snippet.php'…~F")
     (put-file "compiled/snippet.php" _)
     (terpri)])
(quit)
