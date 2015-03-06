; tré – Copyright (c) 2014–2015 Sven Michael Klose <pixel@copei.de>

(defvar *universe* nil)
(defvar *variables* nil)
(defvar *launchfile* nil)
(defvar *pointer-size* 4)
(defvar *assert* t)
(defvar *targets* ,`',*targets*)
(defvar *endianess* nil)
(defvar *cpu-type* nil)
(defvar *libc-path* nil)
(defvar *rand-max* nil)
(defvar *print-definitions?* nil)
(defvar *default-stream-tabsize* 8)

(defvar *quasiquoteexpand-hook* nil)
(defvar *dotexpand-hook* nil)
