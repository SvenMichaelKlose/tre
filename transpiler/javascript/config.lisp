;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Configuration

(defun make-javascript-transpiler ()
  (create-transpiler
	:std-macro-expander 'js-alternate-std
	:macro-expander 'javascript
	:separator (format nil ";~%")
	:unwanted-functions '($ cons car cdr make-hash-table map)
	:identifier-char?
	  #'(lambda (x)
		  (or (and (>= x #\a) (<= x #\z))
		  	  (and (>= x #\A) (<= x #\Z))
		  	  (and (>= x #\0) (<= x #\9))
			  (in=? x #\_ #\. #\$ #\#)))))

(defvar *js-transpiler* (make-javascript-transpiler))
(defvar *js-separator* (transpiler-separator *js-transpiler*))
