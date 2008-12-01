;;;; TRE environment
;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Alien interface.

(env-load "alien/memory.lisp")

(env-load "alien/x86.lisp")
(env-load "alien/amd64.lisp")

(env-load "alien/c-call.lisp")
(env-load "alien/alien.lisp")
(env-load "alien/exec.lisp")
(env-load "../lib/xml2lml.lisp")
(env-load "alien/unix.lisp")
(env-load "alien/import.lisp")
