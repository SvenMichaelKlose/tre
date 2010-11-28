;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(defvar *php-version* 503)

(defun php-setf-functionp (x)
  (or (%setf-functionp x)
      (transpiler-function-arguments *php-transpiler* x)))

(defun make-php-transpiler-0 ()
  (create-transpiler
	  :std-macro-expander 'php-alternate-std
	  :macro-expander 'php
	  :setf-functionp #'php-setf-functionp
	  :unwanted-functions '(wait)
	  :apply-argdefs? nil
	  :literal-conversion #'transpiler-expand-characters
	  :identifier-char?
	    (fn (or (and (>= _ #\a) (<= _ #\z))
		  	    (and (>= _ #\A) (<= _ #\Z))
		  	    (and (>= _ #\0) (<= _ #\9))
			    (in=? _ #\_ #\. #\#)))
	  :gen-string (fn c-literal-string _ #\')
	  :lambda-export? t
	  :stack-locals? nil
	  :rename-all-args? t
	  :inline-exceptions '(%slot-value error format identity %bind)
	  :named-functions? t
	  :named-function-next #'cddr))

(defun make-php-transpiler ()
  (with (tr (make-php-transpiler-0)
    	 ex (transpiler-expex tr))
    (setf (expex-inline? ex)
			  #'%slot-value?
    	  (expex-setter-filter ex)
			  (fn php-setter-filter *php-transpiler* _)
    	  (expex-function-arguments ex)
			  #'current-transpiler-function-arguments-w/o-builtins
    	  (expex-argument-filter ex)
		      #'php-expex-literal)

	(apply #'transpiler-add-obfuscation-exceptions
		tr
	    '(t this %funinfo false true null
		  %transpiler-native %transpiler-string
		  lambda function
		  &key &optional &rest
		  table tbody td tr ul li hr img div p html head body a href src
		  h1 h2 h3 h4 h5 h6 h7 h8 h9
		  fun hash class

		  navigator user-agent index-of

		  ; PHP core
		  apply length push shift unshift
		  split object *array *string == === + - * /

		  __construct))
	(transpiler-add-defined-function tr '%cons)
	(transpiler-add-function-args tr '%cons '(a b))
	tr))

(defvar *php-transpiler* (make-php-transpiler))
(defvar *php-newline* (format nil "~%"))
(defvar *php-separator* (format nil ";~%"))
(defvar *php-indent* "    ")
