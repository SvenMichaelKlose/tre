; tré – Copyright (c) 2014–2015 Sven Michael Klose <pixel@hugbox.org>

; Use to debug...
;(proclaim '(optimize (speed 0) (space 0) (safety 3) (debug 3)))

; Use if happy...
;(proclaim '(optimize (speed 3) (space 3) (safety 0) (debug 0)))

; Don't be noisier than the C core.
(declaim #+sbcl(sb-ext:muffle-conditions compiler-note style-warning))

(load "cl/init.lisp")
(load "cl/core.lisp")

(in-package :tre)

(env-load "main.lisp") 
