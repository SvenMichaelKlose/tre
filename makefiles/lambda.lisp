(load "environment/platforms/shared/html/doctypes.lisp")
(load "environment/platforms/shared/html/script.lisp")

(alet *c-transpiler*
  nil
  ;(= (transpiler-cps-transformation? !) t)
  ;(= (transpiler-backtrace? !) nil)
  ;(= (transpiler-dump-passes? !) t))

(unix-sh-mkdir "compiled")
(make-project "Single–file test."
              '("lambda.lisp")
              :transpiler  *c-transpiler*
              :emitter     [put-file "compiled/lambda.c" _])
(quit)
