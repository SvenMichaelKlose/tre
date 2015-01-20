; tré – Copyright (c) 2014–2015 Sven Michael Klose <pixel@copei.de>

; Symbols directly imported from package CL-USER.
(defconstant +cl-direct-imports+
    '(atom apply
      cons car cdr rplaca rplacd
      list last copy-list nthcdr nth mapcar
      elt length make-string
      mod sqrt sin cos atan exp round floor logxor bit-and
      aref char-code
      make-package package-name find-package
      print))

; Functions we import from CL-USER, wrap and export to package TRE.
(defconstant +cl-renamed-imports+
    '((cons? consp)
      (symbol? symbolp)
      (function? functionp)
      (string? stringp)
      (array? arrayp)
      (character? characterp)
      (%code-char code-char)
      (number< <)
      (integer< <)
      (character< <)
      (number> >)
      (integer> >)
      (character> >)
      (%error error)
      (%nconc nconc)))

; Global variables provided by all tré cores.
(defconstant +cl-core-variables+
    '(*universe* *variables* *functions*
      *environment-path* *environment-filenames*
      *macroexpand-hook* *quasiquoteexpand-hook* *dotexpand-hook*
      *default-listprop* *keyword-package*
      *pointer-size* *launchfile*
      *assert* *targets*
      *endianess* *cpu-type* *libc-path* *rand-max*))
