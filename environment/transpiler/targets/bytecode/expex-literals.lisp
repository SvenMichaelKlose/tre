;;;;; tré – Copyright (c) 2009–2012 Sven Michael Klose <pixel@copei.de>

(defun bc-make-decl (name)
  (format nil "treptr ~A;~%" (transpiler-symbol-string *current-transpiler* name)))

;;;;; Make declarations, initialisations and references to literals.

(defmacro bc-define-compiled-literal (name (x table) &key maker init-maker)
  `(define-compiled-literal ,name (,x ,table)
	   :maker ,maker
	   :init-maker ,init-maker
	   :decl-maker #'bc-make-decl))

(bc-define-compiled-literal bc-compiled-number (x number)
  :maker ($ 'trenumber_compiled_ (gensym-number))
  :init-maker (tregc_push_compiled (trenumber_get (%transpiler-native ,x))))

(bc-define-compiled-literal bc-compiled-char (x char)
  :maker ($ 'trechar_compiled_ (char-code x))
  :init-maker (tregc_push_compiled (trechar_get (%transpiler-native ,(char-code x)))))

(bc-define-compiled-literal bc-compiled-string (x string)
  :maker ($ 'trestring_compiled_ (gensym-number))
  :init-maker (tregc_push_compiled (trestring_get (%transpiler-native (%transpiler-string ,x)))))

(bc-define-compiled-literal bc-compiled-symbol (x symbol)
  :maker ($ 'tresymbol_compiled_ x (? (keyword? x) '_keyword ""))
  :init-maker (tregc_push_compiled (treatom_get (%transpiler-native (%transpiler-string ,(symbol-name x)))
			                                    ,(? (keyword? x)
				                                    'tre_package_keyword
				                                    'treptr_nil))))

(defun bc-expex-argument-filter (x)
  (?
	(cons? x) (transpiler-import-from-expex x)
    (| (character? x) (number? x) (string? x)) (print `(%quote ,x))
	(funinfo-in-this-or-parent-env? *expex-funinfo* x) x
	(expex-funinfo-defined-variable? x) `(treatom_get_value ,(bc-compiled-symbol x))
	x))

(defun bc-expex-filter (x)
  (& (cons? x) (symbol? x.)
     (bc-compiled-symbol x.))
  (transpiler-import-from-expex x))
