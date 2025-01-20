(defsystem "tre"
  :description "tré Lisp transpiler"
  :version "0.0.0"
  :author "Sven Michael Klose"
  :components ((:file "boot-common"))
  :around-compile (lambda (thunk)
                    (proclaim '(optimize (debug 3) (safety 3) (speed 1) (space 0)))
                    (funcall thunk)))
