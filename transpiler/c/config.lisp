;;;;; TRE to C transpiler
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Configuration

(defun make-c-transpiler ()
  (create-transpiler
	:std-macro-expander 'c-alternate-std
	:macro-expander 'c
	:separator (format nil ";~%")
	:unwanted-functions t ; Don't compile dependencies.
	:identifier-char?
	  #'(lambda (x)
		  (or (and (>= x #\a) (<= x #\z))
		  	  (and (>= x #\A) (<= x #\Z))
		  	  (and (>= x #\0) (<= x #\9))
			  (in=? x #\_ #\. #\$ #\#)))
	:make-label
	  (fn (format nil "l~A:" (transpiler-symbol-string *c-transpiler* _)))
	:named-functions? t))

(defvar *c-transpiler* (make-c-transpiler))
(defvar *c-separator* (transpiler-separator *c-transpiler*))
