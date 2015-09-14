; tré – Copyright (c) 2008–2015 Sven Michael Klose <pixel@copei.de>

(= *allow-redefinitions?* t)
(= *have-compiler?* t)
(= *have-c-compiler?* nil)
;(= (transpiler-dump-passes? *js-transpiler*) t)

(unix-sh-mkdir "compiled" :parents t)
(make-project "tré node.js console"
              `((toplevel . ((format t "Welcome to tr&eacute;, revision ~A. Copyright (c) 2005-2015 Sven Michael Klose &lt;pixel@copei.de&gt;~%" *tre-revision*))))
              :transpiler  (aprog1 (copy-transpiler *js-transpiler*)
                             (= (transpiler-configuration ! :save-sources?) t))
              :emitter     [(format t "Writing to 'compiled/nodeconsole.js'…~F")
                            (put-file "compiled/nodeconsole.js" _)
                            (terpri)])
(quit)
