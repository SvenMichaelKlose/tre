;;;;; TRE transpiler
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defmacro php-define-compiled-literal (name (x table) &key maker setter)
  `(define-compiled-literal ,name (,x ,table)
	   :maker ,maker
	   :setter ,setter
	   :decl-maker (fn identity nil))) ; APPLY doesn't ignore NIL.

(php-define-compiled-literal php-compiled-number (x number)
  :maker ($ 'trenumber_compiled_ (gensym-number))
  :setter (%transpiler-native ,x))

(php-define-compiled-literal php-compiled-char (x char)
  :maker ($ 'trechar_compiled_ (char-code x))
  :setter (%transpiler-native "new __trechar (" ,(char-code x) ")"))

(php-define-compiled-literal php-compiled-string (x string)
  :maker ($ 'trestring_compiled_ (gensym-number))
  :setter (%transpiler-native (%transpiler-string ,x)))

(php-define-compiled-literal php-compiled-symbol (x symbol)
  :maker ($ 'tresymbol_compiled_
			x
			(if (keywordp x)
	     	    '_keyword
		 	    ""))
  :setter (%transpiler-native
			  "new __tresym ("
			  	  (%transpiler-string ,(symbol-name x))
				  ","
			   	  ,(keywordp x)
				  ")"))

;; An EXPEX-ARGUMENT-FILTER.
(defun php-expex-literal (x)
  (if
    (characterp x)
      (php-compiled-char x)
    (numberp x)
	  (php-compiled-number x)
    (stringp x)
	  (php-compiled-string x)
	(atom x)
     (if (expex-global-variable? x)
	     (transpiler-add-wanted-variable *php-transpiler* x)
         x)
    (transpiler-import-from-expex x)))
