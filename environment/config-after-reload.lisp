(= *default-transpiler* *cl-transpiler*)
(var *tre-path* (getenv "TRE_PATH"))
(var *modules-path* (print (+ *tre-path* "/modules/")))
