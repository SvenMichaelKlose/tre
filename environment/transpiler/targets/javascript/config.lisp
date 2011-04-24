;;;;; Transpiler: TRE to ECMAScript
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(defun js-setf-function? (x)
  (or (%setf-function? x)
      (transpiler-function-arguments *js-transpiler* x)))

(defun make-javascript-transpiler-0 ()
  (create-transpiler
	  :std-macro-expander 'js-alternate-std
	  :macro-expander 'javascript
	  :setf-function? #'js-setf-function?
	  :unwanted-functions '(wait)
	  :named-functions? nil
	  :apply-argdefs? t
	  :literal-conversion #'transpiler-expand-characters
	  :identifier-char?
	    (fn (or (and (>= _ #\a) (<= _ #\z))
		  	    (and (>= _ #\A) (<= _ #\Z))
		  	    (and (>= _ #\0) (<= _ #\9))
			    (in=? _ #\_ #\. #\$ #\#)))
	  :lambda-export? nil
	  :continuation-passing-style? nil
	  :needs-var-declarations? t
	  :stack-locals? nil
	  :rename-all-args? t
	  :rename-toplevel-function-args? t
	  :predefined-symbols '(window document true)
	  :inline-exceptions '(%slot-value error format identity %bind)
	  :dont-inline-list '(%slot-value error format identity %bind map apply maphash)
      :place-expand-ignore-toplevel-funinfo? t))

(defun make-javascript-transpiler ()
  (with (tr (make-javascript-transpiler-0)
    	 ex (transpiler-expex tr))
    (setf (expex-inline? ex) #'%slot-value?
    	  (expex-setter-filter ex) #'expex-collect-wanted-variable
    	  (expex-function-arguments ex) #'current-transpiler-function-arguments-w/o-builtins
    	  (expex-argument-filter ex) #'expex-%setq-collect-wanted-global-variable)
	(apply #'transpiler-add-obfuscation-exceptions tr
	    '(t this %funinfo false true null delete
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
(defvar *js-indent* "")
