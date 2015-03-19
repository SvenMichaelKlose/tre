; tré – Copyright (c) 2014–2015 Sven Michael Klose <pixel@copei.de>

(defconstant +cl-symbol-imports+
    '(nil t
      setq cond progn block return-from tagbody go labels
      quote function lambda
      &rest &body &optional &key))

(defconstant +cl-core-symbols+
    '(backquote quasiquote quasiquote-splice
      square curly accent-circonflex))

(defconstant +cl-function-imports+
    '(atom apply
      cons car cdr rplaca rplacd
      list last copy-list nthcdr nth mapcar
      length make-string
      mod sqrt sin cos atan exp round floor
      aref char-code
      make-package package-name find-package
      print
      invoke-debugger))

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
    '(%defun-quiet %defun %defvar %defmacro ?))
