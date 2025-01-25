(unix-sh-mkdir "compiled" :parents t)
(make-project
  :name
    "Compile tré Lisp expression to JS"
  :transpiler
    (aprog1 (copy-transpiler *js-transpiler*)
      (= (transpiler-dump-passes? !) nil)    ; XXX required?
      (= (transpiler-configuration ! :save-sources?) nil))
  :emitter
    [(format t "Writing to 'compiled/snippet.html'…~F")
     (make-html-script "compiled/snippet.html" _)
     (terpri)]
  :sections
    `((toplevel . ((print 'add-your-test-here)))))
(quit)
