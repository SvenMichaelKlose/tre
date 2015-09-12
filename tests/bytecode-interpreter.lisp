; tré – Copyright (c) 2014–2015 Sven Michael Klose <pixel@hugbox.org>

(defvar @bctest-global-with-fun nil)

(defun @bc-test-%set-local-fun ()
  (%set-local-fun @bctest-global-with-fun 'wannabe-fun)
  (symbol-value '@bctest-global-with-fun))

(defun @bc-test-set-lexical ()
  (with (a 42
         fun #'((x)
                  (= a x)))
    (fun 65)
    a))

(defun @bc-test-closure ()
  (with (a 42
         fun #'((x)
                  (= a x))
         fun2 #'((f)
                  (apply f)))
    (fun2 #'(() (fun 65)))
    a))

(defun @bc-test-closure ()
  (with (a 42
         fun #'((x)
                  (= a x))
         fun2 #'((f)
                  (apply f)))
    (fun2 #'(() (fun 65)))
    a))

(defun bytecode-interpreter-tests ()
  (load-bytecode (compile-bytecode-environment '(@bc-test-%set-local-fun
                                                 @bc-test-set-lexical
                                                 @bc-test-closure)))

  (print '@bc-test-%set-local-fun)
  (alet (@bc-test-%set-local-fun)
    (unless (eq 'wannabe-fun !)
      (print !)
      (error "%SET-LOCAL-FUN isn't handled correctly by the bytecode interpreter.")))

  (print '@bc-test-set-lexical)
  (alet (@bc-test-set-lexical)
    (unless (== 65 !)
      (print !)
      (error "Lexicals aren't set correctly by the bytecode interpreter.")))

  (print '@bc-test-closure)
  (alet (@bc-test-closure)
    (unless (== 65 !)
      (print !)
      (error "Closures aren't handled correctly by the bytecode interpreter.")))

  (format t "Bytecode interpreter tests passed.~%")
  (terpri))

(bytecode-interpreter-tests)
(quit)
