;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(unix-sh-mkdir "compiled")
(make-project "tré JavaScript target test"
              `("environment/transpiler/debugger/toplevel.lisp")
              :transpiler *js-transpiler*
              :emitter     [put-file "compiled/debugger.js" _])
(quit)
