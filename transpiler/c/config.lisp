;;;;; TRE to C transpiler
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Configuration

(defun make-c-transpiler ()
  (create-transpiler
	:std-macro-expander 'c-alternate-std
	:macro-expander 'c
	:separator (format nil ";~%")
	;:unwanted-functions  ; Don't compile dependencies.
	:identifier-char?
	  (fn (or (and (>= _ #\a) (<= _ #\z))
		  	  (and (>= _ #\A) (<= _ #\Z))
		  	  (and (>= _ #\0) (<= _ #\9))
			  (in=? _ #\_ #\. #\$ #\#)))
	:make-label
	  (fn (format nil "l~A:" (transpiler-symbol-string *c-transpiler* _)))
	:named-functions? t
	:lambda-export? t
	:stack-arguments? t))

(defvar *c-transpiler* (make-c-transpiler))
(defvar *c-separator* (transpiler-separator *c-transpiler*))
