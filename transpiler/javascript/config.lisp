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
	:thisify-classes nil
	:obfuscate? nil
	:obfuscation-exceptions
	  '(fun callback

		; JavaScript core
		apply length push shift unshift

		; DOM
		document cursor style element 
		client-x client-y
		client-left client-top
		scroll-left scroll-top
		page-x page-y
		body

		; Event
		type button char-code key-code target)
	:identifier-char?
	  #'(lambda (x)
		  (or (and (>= x #\a) (<= x #\z))
		  	  (and (>= x #\A) (<= x #\Z))
		  	  (and (>= x #\0) (<= x #\9))
			  (in=? x #\_ #\. #\$ #\#)))
	:make-label
	  #'((x)
           (format nil "case \"~A\":~%" (transpiler-symbol-string *js-transpiler* a)))))

(defvar *js-transpiler* (make-javascript-transpiler))
(defvar *js-separator* (transpiler-separator *js-transpiler*))
