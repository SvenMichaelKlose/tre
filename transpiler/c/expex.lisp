;;;;; TRE transpiler
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defmacro c-define-compiled-literal (name (x table) maker setter)
  `(progn
	 (defvar ,table (make-hash-table :test #'eql))
     (defun ,name (,x)
       (or (href ,x ,table)
	   	   (let n ,maker
	      	 (push! (format nil "treptr ~A;~%"
							  	(string-downcase (symbol-name n)))
			        *c-declarations*)
	       	 (push! `(setf ,,n ,setter)
			      	*c-init*)
	       	 (setf (href ,x ,table) n))))))

(c-define-compiled-literal c-compiled-number (x *c-compiled-numbers*)
  ($ 'trenumber_compiled_ (gensym-number))
  (trenumber_get (%transpiler-native ,x)))

(c-define-compiled-literal c-compiled-char (x *c-compiled-char*)
  ($ 'trechar_compiled_ (char-code x))
  (trechar_get (%transpiler-native ,(char-code x))))

(c-define-compiled-literal c-compiled-string (x *c-compiled-strings*)
  ($ 'trestring_compiled_ (gensym-number))
  (trestring_get (%transpiler-native (%transpiler-string ,(escape-string x)))))

(c-define-compiled-literal c-compiled-symbol (x *c-compiled-symbols*)
  ($ 'tresymbol_compiled_ (gensym-number))
  (treatom_get (%transpiler-native (%transpiler-string ,(escape-string (symbol-name x))))
			   ,(when (keywordp x)
				  'trepackage_keyword
				  'treptr_nil)))

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

(defun c-local-fun-filter (x)
  (if (and (consp (third x))
		   (%vec? (first (third x))))
	  `(%setq ,(second x) (funcall ,(first (third x))
								   ,(compiled-list (cdr (third x)))))
	  x))

(defun c-setter-filter (y)
  (let x (c-local-fun-filter y)
    (if
	  (expex-global-variable? (second x))
	    `(%setq-atom (%no-expex ,(symbol-name (second x)))
				     ,@(cddr x))
	    x)))
