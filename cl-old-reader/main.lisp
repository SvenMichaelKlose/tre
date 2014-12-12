;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(proclaim '(optimize (speed 3) (space 0) (safety 3) (debug 3)))

(load "cl-old-reader/init.lisp")
(load "cl-old-reader/core.lisp")
(load "cl-old-reader/user.lisp")

(in-package :tre)

(env-load "stage0/main.lisp")
(env-load "main.lisp") 
