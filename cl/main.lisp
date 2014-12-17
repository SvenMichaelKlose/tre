;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(proclaim '(optimize (speed 3) (space 3) (safety 0) (debug 0)))

(load "cl/init.lisp")
(load "cl/core.lisp")

(in-package :tre)

(env-load "stage0/main.lisp")
(env-load "main.lisp") 
