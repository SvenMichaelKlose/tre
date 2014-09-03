;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@hugbox.org>

(defvar @bctest-global-with-fun nil)

(defun @bc-test-%set-atom-fun ()
  ; %SET-ATOM-FUN is converted to =-SYMBOL-VALUE and shouldn't be in hard-wired
  ; in the interpreter.
  (%set-atom-fun @bctest-global-with-fun 'wannabe-fun)
  (symbol-value '@bctest-global-with-fun))

(defun bytecode-interpreter-tests ()
  (= (transpiler-dump-passes? *bc-transpiler*) t)

  (load-bytecode (compile-bytecode-environment '@bc-test-%set-atom-fun))
  (alet (@bc-test-%set-atom-fun)
    (unless (eq 'wannabe-fun !)
      (print !)
      (error "%SET-ATOM-FUN isn't handled correctly by the bytecode interpreter.")))

  (load-bytecode (compile-bytecode-environment 'princ))
  (princ "This should be a properly printed string.")
  (terpri))
