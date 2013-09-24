;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defun c-make-decl (name)
  (format nil "treptr ~A;~%" (transpiler-symbol-string *transpiler* name)))

;;;;; Make declarations, initialisations and references to literals.

(defmacro c-define-compiled-literal (name (x table) &key maker init-maker)
  `(define-compiled-literal ,name (,x ,table)
	   :maker      ,maker
	   :init-maker ,init-maker
	   :decl-maker #'c-make-decl))

(c-define-compiled-literal c-compiled-number (x number)
  :maker ($ 'trenumber_compiled_ (gensym-number))
  :init-maker `(tregc_add_unremovable (trenumber_get (%%native ,x))))

(c-define-compiled-literal c-compiled-char (x char)
  :maker ($ 'trechar_compiled_ (char-code x))
  :init-maker `(tregc_add_unremovable (trechar_get (%%native ,(char-code x)))))

(c-define-compiled-literal c-compiled-string (x string)
  :maker ($ 'trestring_compiled_ (gensym-number))
  :init-maker `(tregc_add_unremovable (trestring_get (%%native (%%string ,x)))))

(c-define-compiled-literal c-compiled-symbol (x symbol)
  :maker ($ 'tresymbol_compiled_ x (? (keyword? x) '_keyword ""))
  :init-maker `(tregc_add_unremovable (treatom_get (%%native (%%string ,(symbol-name x)))
			                                       ,(? (keyword? x)
				                                       'tre_package_keyword
				                                       'treptr_nil))))

(functional *TRESYMBOL_VALUE*)

(defun c-argument-filter (x)
  (?
    (global-literal-symbol-function? x)    `(symbol-function ,(c-compiled-symbol .x.))
	(cons? x)      x
    (character? x) (c-compiled-char x)
    (number? x)    (c-compiled-number x)
    (string? x)    (c-compiled-string x)
	(funinfo-var-or-lexical? *funinfo* x)  x
	(funinfo-global-variable? *funinfo* x) `(symbol-value ,(c-compiled-symbol x))
	x))
