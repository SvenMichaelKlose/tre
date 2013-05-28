;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defmacro php-define-compiled-literal (name (x table) &key maker init-maker)
  `(define-compiled-literal ,name (,x ,table)
	   :maker ,maker
	   :init-maker ,init-maker
	   :decl-maker [identity nil])) ; APPLY doesn't ignore NIL.

(php-define-compiled-literal php-compiled-char (x char)
  :maker (transpiler-add-late-symbol *transpiler* ($ 'trechar_compiled_ (char-code x)))
  :init-maker (%%native "new __character (" ,(char-code x) ")"))

(php-define-compiled-literal php-compiled-symbol (x symbol)
  :maker ($ 'tresymbol_compiled_ x (? (keyword? x) '_keyword ""))
  :init-maker (%%native "new __symbol ("
			  	            (%%string ,(symbol-name x))
                            ","
			   	            ,(? (keyword? x)
                                "$KEYWORDPACKAGE"
                                "NULL")
				        ")"))

(defun php-expex-add-global (x)
  (funinfo-var-add (transpiler-global-funinfo *transpiler*) x)
  (adjoin! x (funinfo-globals *expex-funinfo*))
  x)

(defun php-global (x)
  `(%%native "$GLOBALS['" ,(transpiler-obfuscated-symbol-string *transpiler* x) "']"))

(defun php-expex-argument-filter (x)
  (?
    (& (atom x)
       (not (eq '~%RET x))
       (not (funinfo-toplevel-var? *expex-funinfo* x))
       (expex-global-variable? x))
      (progn
        (transpiler-add-wanted-variable *transpiler* x)
        (php-global x))
    (character? x) (php-expex-add-global (php-compiled-char x))
    (%quote? x)    (php-expex-add-global (php-compiled-symbol .x.))
    (keyword? x)   (php-expex-add-global (php-compiled-symbol x))
	(atom x)       x
    (transpiler-import-from-expex x)))
