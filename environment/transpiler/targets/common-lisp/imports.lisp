; tré – Copyright (c) 2014–2016 Sven Michael Klose <pixel@hugbox.org>

(defconstant +cl-symbol-imports+
    '(nil t
      setq cond progn block return-from tagbody go labels
      quote function lambda slot-value
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
      break))

(defconstant +cl-renamed-imports+
    '((cons? consp)
      (symbol? symbolp)
      (function? functionp)
      (string? stringp)
      (array? arrayp)
      (number? numberp)
      (character? characterp)
      (integer floor)
      (%code-char code-char)
      (- -)
      (* *)
      (/ /)
      (== =)
      (< <)
      (> >)
      (<= <=)
      (>= >=)
      (%* *)
      (%/ /)
      (number== =)
      (number+ +)
      (number- -)
      (number* *)
      (number/ /)
      (number< <)
      (number> >)
      (integer== =)
      (integer+ +)
      (integer- -)
      (integer* *)
      (integer/ /)
      (integer< <)
      (integer> >)
      (character== char=)
      (character< char<)
      (character> char>)))

(defconstant +cl-special-forms+
    '(%defun-quiet %defun %defvar %defmacro ?))
