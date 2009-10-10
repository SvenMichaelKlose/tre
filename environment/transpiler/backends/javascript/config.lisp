;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Configuration

(defun js-setf-functionp (x)
  (or (%setf-functionp x)
      (transpiler-function-arguments *js-transpiler* x)))

(defun js-transpiler-make-label (x)
  (format nil "case ~A:~%" (transpiler-symbol-string *js-transpiler* x)))

(defun make-javascript-transpiler-0 ()
  (create-transpiler
	  :std-macro-expander 'js-alternate-std
	  :macro-expander 'javascript
	  :setf-functionp #'js-setf-functionp
	  :unwanted-functions '(wait)
	  :apply-argdefs? t
	  :literal-conversion #'transpiler-expand-characters
	  :identifier-char?
	    (fn (or (and (>= _ #\a) (<= _ #\z))
		  	    (and (>= _ #\A) (<= _ #\Z))
		  	    (and (>= _ #\0) (<= _ #\9))
			    (in=? _ #\_ #\. #\$ #\#)))
	  :make-label #'js-transpiler-make-label
	  :lambda-export? nil
	  :stack-locals? nil
	  :rename-all-args? t
	  :inline-exceptions '(%slot-value error format identity %bind)))

(defun make-javascript-transpiler ()
  (with (tr (make-javascript-transpiler-0)
    	 ex (transpiler-expex tr))
    (setf (expex-inline? ex)
			  #'%slot-value?
    	  (expex-setter-filter ex)
			  #'expex-collect-wanted-variable
    	  (expex-function-arguments ex)
			  #'js-function-arguments
    	  (expex-argument-filter ex)
		      #'expex-%setq-collect-wanted-global-variable)

	(apply #'transpiler-add-obfuscation-exceptions
		tr
	    '(t this %funinfo false true null
		  %transpiler-native %transpiler-string
		  lambda function
		  &key &optional &rest
		  prototype
		  table tbody td tr ul li hr img div p html head body a href src
		  h1 h2 h3 h4 h5 h6 h7 h8 h9
		  fun hash class

		  navigator user-agent index-of

		  ; JavaScript core
		  apply length push shift unshift
		  split object *array *string == === + - * /

		  alert))
	tr))

(defvar *js-transpiler* (make-javascript-transpiler))
(defvar *js-newline* (format nil "~%"))
(defvar *js-separator* (format nil ";~%"))
