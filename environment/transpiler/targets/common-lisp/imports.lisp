(defconstant +cl-symbol-imports+
    '(nil t
      setq cond progn block return-from tagbody go labels
      quote function lambda slot-value
      &rest &body &optional &key))

(defconstant +cl-core-symbols+
    '(backquote quasiquote quasiquote-splice
      square curly braces accent-circonflex))

(defconstant +cl-function-imports+
    '(apply
      cons car cdr rplaca rplacd
      length make-string
      mod sqrt sin cos tan asin acos atan exp round floor
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
      (character== char=)
      (character< char<)
      (character> char>)
      (pow expt)))

(defconstant +cl-special-forms+
    '(%defun-quiet %defun %defvar %defmacro ?))
