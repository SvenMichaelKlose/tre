;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defun transpiler-expand-characters (x)
  (if
	(characterp x)
	  `(code-char ,(char-code x))
    (consp x)
	  (traverse #'transpiler-expand-characters x)
	x))

(defun js-setter-filter (tr x)
  (transpiler-add-wanted-variable tr (second x))
  x)

;; XXX move to env
(defun global-variable? (x)
  (assoc x *variables*))

;; XXX Move to expex.
(defun expex-in-env? (x)
  (when (atom x)
    (funinfo-in-this-or-parent-env? *expex-funinfo* x)))

;; XXX Move to expex.
(defun expex-global-variable? (x)
  (and (atom x)
	   (not (expex-in-env? x))
	   (global-variable? x)))

(defun c-compiled-char (x)
  ; XXX Memorize number.
  ($ 'trechar_compiled_ (char-code x)))

(defun c-compiled-number (x)
  ; XXX Memorize number.
  ($ 'trenumber_compiled_ x))

(defun c-compiled-string (x)
  ; XXX Memorize number.
  ($ 'trestring_compiled_ (gensym)))

(defun c-expand-literals (x)
  (if
    (characterp x)
      (c-compiled-char x)
    (numberp x)
      (c-compiled-number x)
    (stringp x)
	  (c-compiled-string x)
	(expex-global-variable? x)
	  `(treatom_get_value (%no-expex ,(symbol-name x)))
    x))

(defun c-setter-filter (x)
  (if (expex-global-variable? (second x))
	  `(%setq-atom (%no-expex ,(symbol-name (second x)))
				   ,@(cddr x))
	  x))
