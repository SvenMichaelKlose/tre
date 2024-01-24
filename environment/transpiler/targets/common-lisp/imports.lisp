(defconstant +cl-symbol-imports+
    '(nil t
      setq cond progn block return-from tagbody go labels
      quote function lambda slot-value
      &rest &body &optional &key))

(defconstant +cl-core-symbols+
    '(backquote quasiquote quasiquote-splice
      brackets braces))

(defconstant +cl-function-imports+
    '(apply
      cons car cdr rplaca rplacd
      length make-string
      mod sqrt sin cos tan asin acos atan exp round floor
      aref char-code
      make-package package-name find-package
      print))

(defconstant +cl-renamed-imports+
    '((cons?        CONSP)
      (symbol?      SYMBOLP)
      (function?    FUNCTIONP)
      (string?      STRINGP)
      (array?       ARRAYP)
      (number?      NUMBERP)
      (character?   CHARACTERP)
      (integer      FLOOR)
      (%code-char   CODE-CHAR)
      (-            -)
      (*            *)
      (/            /)
      (==           =)
      (<            <)
      (>            >)
      (<=           <=)
      (>=           >=)
      (%*           *)
      (%/           /)
      (number==     =)
      (number+      +)
      (number-      -)
      (number*      *)
      (number/      /)
      (number<      <)
      (number>      >)
      (character==  CHAR=)
      (character<   CHAR<)
      (character>   CHAR>)
      (pow          EXPT)))

(defconstant +cl-special-forms+
    '(%fn-quiet %fn %defvar %defmacro ?))
