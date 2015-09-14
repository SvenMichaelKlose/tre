; tré – Copyright (c) 2008–2015 Sven Michael Klose <pixel@copei.de>

(= *allow-redefinitions?* t)
(= *have-compiler?* t)
(= *have-c-compiler?* nil)
;(= (transpiler-dump-passes? *js-transpiler*) t)

(unix-sh-mkdir "compiled" :parents t)
(make-project "tré web console"
              `((toplevel . ((format t "Welcome to tr&eacute;, revision ~A. Copyright (c) 2005-2015 Sven Michael Klose &lt;pixel@copei.de&gt;~%" *tre-revision*))))
              :transpiler  (aprog1 (copy-transpiler *js-transpiler*)
                             (= (transpiler-configuration ! :save-sources?) nil))
              :emitter     [(format t "Writing to 'compiled/boot-node.js'…~F")
                            (put-file "compiled/boot-node.js" _)
                            (terpri)])
(quit)
