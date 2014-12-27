; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defvar *universe* nil)
(defvar *variables* nil)
(defvar *launchfile* nil)
(defvar *pointer-size* 4)
(defvar *assert* t)
(defvar *targets* '(:c :cl :js :php))
(defvar *endianess* nil)
(defvar *cpu-type* nil)
(defvar *libc-path* nil)
(defvar *rand-max* nil)

(defvar *quasiquoteexpand-hook* nil)
(defvar *dotexpand-hook* nil)
