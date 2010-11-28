;;;;; TRE to C transpiler
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Configuration

(defun make-c-transpiler ()
  (let tr (create-transpiler
			  :std-macro-expander 'c-alternate-std
			  :macro-expander 'c
			  :separator (format nil ";~%")
			  :inline-exceptions (list 'c-init)
			  :dont-inline-list '(error format)
			  :identifier-char?
	  		      (fn (or (and (>= _ #\a) (<= _ #\z))
		  	  		      (and (>= _ #\A) (<= _ #\Z))
		  	  		      (and (>= _ #\0) (<= _ #\9))
			  		      (in=? _ #\_ #\. #\$ #\#)))
			  :named-functions? t
			  :named-function-next #'cdddr
			  :lambda-export? t
			  :stack-locals? t
			  :rename-all-args? t
			  :literal-conversion #'identity)
	(setf (transpiler-inline-exceptions tr) '(error format identity))
	(let ex (transpiler-expex tr)
	  (setf (expex-argument-filter ex) #'c-expex-literal
			(expex-setter-filter ex) (compose #'expex-set-global-variable-value
										      #'expex-compiled-funcall)
			));(expex-inline? ex) (fn in? _ 'aref '%vec '%car '%cdr '%eq '%not)))
	tr))

(defvar *c-transpiler* (make-c-transpiler))
(defvar *c-separator* (transpiler-separator *c-transpiler*))
(defvar *c-newline* (format nil "~%"))
(defvar *c-indent* "    ")
