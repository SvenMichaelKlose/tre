;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@hugbox.org>

(defvar @bctest-global-with-fun nil)

(defun @bc-test-%set-atom-fun ()
  (%set-atom-fun @bctest-global-with-fun 'wannabe-fun)
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
  (load-bytecode (compile-bytecode-environment '(@bc-test-%set-atom-fun
                                                 @bc-test-set-lexical
                                                 @bc-test-closure)))

  (alet (@bc-test-%set-atom-fun)
    (unless (eq 'wannabe-fun !)
      (print !)
      (error "%SET-ATOM-FUN isn't handled correctly by the bytecode interpreter.")))

  (alet (@bc-test-set-lexical)
    (unless (== 65 !)
      (print !)
      (error "Lexicals aren't set correctly by the bytecode interpreter.")))

  (alet (@bc-test-closure)
    (unless (== 65 !)
      (print !)
      (error "Closures aren't handled correctly by the bytecode interpreter.")))

  (format t "Bytecode interpreter tests passed.~%")
  (terpri))

(bytecode-interpreter-tests)
(quit)
