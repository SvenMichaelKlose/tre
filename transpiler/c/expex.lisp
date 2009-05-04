;;;;; TRE transpiler
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defmacro c-define-compiled-literal (name (x table) maker setter)
  `(progn
	 (defvar ,table (make-hash-table :test #'eql))
     (defun ,name (,x)
       (or (href ,table ,x)
	   	   (let n ,maker
	      	 (push! (format nil "treptr ~A;~%"
							  	(string-downcase (symbol-name n)))
			        *c-declarations*)
	       	 (push! `(setf ,,n ,setter)
			      	*c-init*)
	       	 (setf (href ,table ,x) n))))))

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

;; An EXPEX-ARGUMENT-FILTER.
(defun c-expand-literals (x)
  (if
    (characterp x)
      (c-compiled-char x)
    (numberp x)
      (c-compiled-number x)
    (stringp x)
	  (c-compiled-string x)
	(expex-global-variable? x)
	  `(treatom_get_value ,(c-compiled-symbol x))
    x))

(defun function-expr? (x)
  (and (consp x)
	   (eq 'FUNCTION x.)))

(defun c-make-%setq-funcall (x f)
  `(%setq ,(second x) (trespecial_apply
						       ,(compiled-list (append (list f)
													   (cdr (third x)))))))

(defun c-local-fun-filter (x)
  (if (consp (third x))
	  (if
	 	 (consp (first (third x)))
	  	   (c-make-%setq-funcall x (first (third x)))
		 (expex-in-env? (first (third x)))
	  	   (c-make-%setq-funcall x (first (third x)))
		 (transpiler-defined-function *c-transpiler* (first (third x)))
	  	   `(%setq ,(second x) (,(c-transpiler-function-name (first (third x)))
						        ,@(cdr (third x))))
		 x)
	x))

;; An EXPEX-SETTER-FILTER.
(defun c-setter-filter (y)
  (let x (c-local-fun-filter y)
    (if
	  (expex-global-variable? (second x))
	    `(%setq-atom ,(second x)
				     ,@(cddr x))
	  x)))
