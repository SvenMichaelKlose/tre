;;;;; TRE transpiler
;;;;; Copyright (c) 2009-2011 Sven Klose <pixel@copei.de>

(defmacro php-define-compiled-literal (name (x table) &key maker init-maker)
  `(define-compiled-literal ,name (,x ,table)
	   :maker ,maker
	   :init-maker ,init-maker
	   :decl-maker (fn identity nil))) ; APPLY doesn't ignore NIL.

(php-define-compiled-literal php-compiled-number (x number)
  :maker ($ 'trenumber_compiled_ (gensym-number))
  :init-maker (%transpiler-native "" ; Tell %SETQ not to make reference assignment.
							      ,x))

(php-define-compiled-literal php-compiled-char (x char)
  :maker ($ 'trechar_compiled_ (char-code x))
  :init-maker (%transpiler-native "new __character (" ,(char-code x) ")"))

(php-define-compiled-literal php-compiled-string (x string)
  :maker ($ 'trestring_compiled_ (gensym-number))
  :init-maker (%transpiler-native "" (%transpiler-string ,x)))

(php-define-compiled-literal php-compiled-symbol (x symbol)
  :maker ($ 'tresymbol_compiled_
			x
			(if (keywordp x)
	     	    '_keyword
		 	    ""))
  :init-maker (%transpiler-native
			      "new __symbol ("
			  	      (%transpiler-string ,(symbol-name x))
				      ",$"
			   	      ,(keywordp x)
				      ")"))

(defun php-expex-add-global (x)
  (adjoin! x (funinfo-globals *expex-funinfo*))
  x)

(defun php-expex-literal (x)
  (if
    (characterp x)
      (php-expex-add-global (php-compiled-char x))
    (numberp x)
	  (php-expex-add-global (php-compiled-number x))
    (stringp x)
	  (php-expex-add-global (php-compiled-string x))
    (%quote? x)
	  (php-expex-add-global (php-compiled-symbol .x.))
	(atom x)
      (if
		(expex-global-variable? x)
	      (progn
            (transpiler-add-wanted-variable *php-transpiler* x)
            (php-expex-add-global x))
		x)
    (transpiler-import-from-expex x)))
