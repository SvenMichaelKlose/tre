;;;;; tré – Copyright (c) 2009–2014 Sven Michael Klose <pixel@copei.de>

(defun c-make-decl (name)
  (format nil "treptr ~A;~%" (obfuscated-identifier name)))

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
  :init-maker `(tregc_add_unremovable (symbol_get (%%native (%%string ,(symbol-name x)))
			                                      ,(? (keyword? x)
				                                      'tre_package_keyword
				                                      'treptr_nil))))
