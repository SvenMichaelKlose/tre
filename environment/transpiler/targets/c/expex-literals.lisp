;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defun c-make-decl (name)
  (format nil "treptr ~A;~%" (transpiler-symbol-string *current-transpiler* name)))

;;;;; Make declarations, initialisations and references to literals.

(defmacro c-define-compiled-literal (name (x table) &key maker init-maker)
  `(define-compiled-literal ,name (,x ,table)
	   :maker ,maker
	   :init-maker ,init-maker
	   :decl-maker #'c-make-decl))

(c-define-compiled-literal c-compiled-number (x number)
  :maker ($ 'trenumber_compiled_ (gensym-number))
  :init-maker (tregc_push_compiled (trenumber_get (%transpiler-native ,x))))

(c-define-compiled-literal c-compiled-char (x char)
  :maker ($ 'trechar_compiled_ (char-code x))
  :init-maker (tregc_push_compiled (trechar_get (%transpiler-native ,(char-code x)))))

(c-define-compiled-literal c-compiled-string (x string)
  :maker ($ 'trestring_compiled_ (gensym-number))
  :init-maker (tregc_push_compiled (trestring_get (%transpiler-native (%transpiler-string ,x)))))

(c-define-compiled-literal c-compiled-symbol (x symbol)
  :maker ($ 'tresymbol_compiled_ x (? (keyword? x) '_keyword ""))
  :init-maker (tregc_push_compiled (treatom_get (%transpiler-native (%transpiler-string ,(symbol-name x)))
			                                    ,(? (keyword? x)
				                                    'tre_package_keyword
				                                    'treptr_nil))))

(defun c-expex-argument-filter (x)
  (?
	(cons? x)      (transpiler-import-from-expex x)
    (character? x) (c-compiled-char x)
    (number? x)    (c-compiled-number x)
    (string? x)    (c-compiled-string x)
	(funinfo-in-env-or-lexical? *expex-funinfo* x) x
	(expex-funinfo-defined-variable? x) `(treatom_get_value ,(c-compiled-symbol x))
	x))

(defun c-expex-filter (x)
  (& (cons? x) (symbol? x.)
     (c-compiled-symbol x.))
  (transpiler-import-from-expex x))
