; tré – Copyright (c) 2014–2015 Sven Michael Klose <pixel@copei.de>

; Symbols directly imported from package CL-USER.
(defconstant +cl-direct-imports+
    '(atom apply
      cons car cdr rplaca rplacd
      list last copy-list nthcdr nth mapcar
      elt length make-string
      mod sqrt sin cos atan exp round floor
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

(defconstant +cl-special-forms+
    '(%defun-quiet %defun %defvar
      %defmacro
      setq
      progn block
      return-from tagbody go
      cond
      labels
      ?))
