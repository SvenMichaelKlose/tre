;;;;; tré – Copyright (c) 2009–2012 Sven Michael Klose <pixel@copei.de>

(defmacro php-define-compiled-literal (name (x table) &key maker init-maker)
  `(define-compiled-literal ,name (,x ,table)
	   :maker ,maker
	   :init-maker ,init-maker
	   :decl-maker (fn identity nil))) ; APPLY doesn't ignore NIL.

(php-define-compiled-literal php-compiled-char (x char)
  :maker (transpiler-add-late-symbol *current-transpiler* ($ 'trechar_compiled_ (char-code x)))
  :init-maker (%transpiler-native "new __character (" ,(char-code x) ")"))

(php-define-compiled-literal php-compiled-symbol (x symbol)
  :maker ($ 'tresymbol_compiled_ x (? (keyword? x) '_keyword ""))
  :init-maker (%transpiler-native
			      "new __symbol ("
			  	      (%transpiler-string ,(symbol-name x))
                      ","
			   	      ,(? (keyword? x)
                          "$KEYWORDPACKAGE"
                          "NULL")
				      ")"))

(defun php-expex-add-global (x)
  (adjoin! x (funinfo-globals *expex-funinfo*))
  x)

(defun php-global (x)
  `(%transpiler-native "$GLOBALS['" ,(transpiler-obfuscated-symbol-string *current-transpiler* x) "']"))

(defun php-expex-argument-filter (x)
  (?
    (& (atom x)
       (not (eq '~%RET x))
       (not (funinfo-in-toplevel-env? *expex-funinfo* x))
       (expex-global-variable? x))
      (progn
        (transpiler-add-wanted-variable *current-transpiler* x)
        (php-global x))
    (character? x) (php-expex-add-global (php-compiled-char x))
    (%quote? x)    (php-expex-add-global (php-compiled-symbol .x.))
    (keyword? x)   (php-expex-add-global (php-compiled-symbol x))
	(atom x)       x
    (transpiler-import-from-expex x)))
