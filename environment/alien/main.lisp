;;;; TRE environment
;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Alien interface.

(env-load "alien/memory.lisp")

(cond
  ((string= *CPU-TYPE* "i386")
	  (env-load "alien/x86.lisp"))
  ((string= *CPU-TYPE* "amd64")
	  (env-load "alien/amd64.lisp"))
  (t  (error "invalid *CPU-TYPE*")))

(env-load "alien/c-call.lisp")
(env-load "alien/alien.lisp")
(env-load "alien/exec.lisp")
(env-load "alien/import.lisp")
