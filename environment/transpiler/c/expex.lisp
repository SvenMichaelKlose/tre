;;;;; TRE transpiler
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defmacro c-define-compiled-literal (name (x table) maker setter)
  (let slot `(,($ 'transpiler-compiled- table 's) *current-transpiler*)
    `(defun ,name (,x)
       (or (href ,slot ,x)
	 	   (let n ,maker
	         (push! (format nil "treptr ~A;~%"
							  	(string-downcase (symbol-name n)))
  					(transpiler-compiled-decls *current-transpiler*))
	       	 (push! `(setf ,,n ,setter)
  					(transpiler-compiled-inits *current-transpiler*))
	       	 (setf (href ,slot ,x) n))))))

(c-define-compiled-literal c-compiled-number (x number)
  ($ 'trenumber_compiled_ (gensym-number))
  (trenumber_get (%transpiler-native ,x)))

(c-define-compiled-literal c-compiled-char (x char)
  ($ 'trechar_compiled_ (char-code x))
  (trechar_get (%transpiler-native ,(char-code x))))

(defun make-c-newlines (x)
  (list-string (tree-list (mapcar (fn (if (= 10 _)
										  (list #\\ #\n)
										  _))
								  (string-list x)))))

(c-define-compiled-literal c-compiled-string (x string)
  ($ 'trestring_compiled_ (gensym-number))
  (trestring_get (%transpiler-native (%transpiler-string ,(make-c-newlines (escape-string x))))))

(c-define-compiled-literal c-compiled-symbol (x symbol)
  ($ 'tresymbol_compiled_
	 (transpiler-symbol-string *current-transpiler* x)
	 (if (keywordp x)
	     '_keyword
		 ""))
  (treatom_get (%transpiler-native (%transpiler-string ,(escape-string (symbol-name x))))
			   ,(if (keywordp x)
				    'tre_package_keyword
				    'treptr_nil)))

(defun atom-function-expr? (x)
  (and (consp x)
	   (eq x. 'function)
	   (atom .x.)
	   .x.))

(defun vec-function-expr? (x)
  (and (consp x)
	   (eq x. 'function)
	   (or (%vec? .x.)
		   (%stack? .x.))
	   .x.))

;; An EXPEX-ARGUMENT-FILTER.
(defun c-expand-literals (x)
  (if
    (characterp x)
      (c-compiled-char x)
    (numberp x)
	  (c-compiled-number x)
    (stringp x)
	  (c-compiled-string x)
	(atom x)
 	  (if
	    (funinfo-arg? *expex-funinfo* x)
		  x
		(or (funinfo-env-pos *expex-funinfo* x)
		    (expex-global-variable? x))
	  	  `(treatom_get_value ,(c-compiled-symbol x))
		x)
    (transpiler-import-from-expex x)))

(defun function-expr? (x)
  (and (consp x)
	   (eq 'FUNCTION x.)))

(defun c-make-%setq-funcall (x f)
  `(%setq ,(second x)
		  (trespecial_apply_compiled
			  (cons ,f (cons ,(compiled-list (cdr (third x)))
							 nil)))))

(defun c-local-fun-filter (x)
  (if
     (not (consp (third x)))
	   x
 	 (consp (first (third x)))
  	   (c-make-%setq-funcall x (first (third x)))
	 (expex-in-env? (first (third x)))
  	   (c-make-%setq-funcall x (first (third x)))
	 (transpiler-defined-function *c-transpiler* (first (third x)))
  	   `(%setq ,(second x)
			   (,(c-transpiler-function-name (first (third x)))
			        ,@(cdr (third x))))
	 x))

;; An EXPEX-SETTER-FILTER.
(defun c-setter-filter (y)
  (let x (c-local-fun-filter y)
    (if
	  (expex-global-variable? (second x))
	    `(%setq-atom ,(second x)
				     ,@(cddr x))
	  x)))
