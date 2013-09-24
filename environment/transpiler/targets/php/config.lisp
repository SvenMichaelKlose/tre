;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defvar *php-version* 503)

(defun php-identifier-char? (x)
  (unless (== #\$ x)
    (c-identifier-char? x)))

(defun php-expex-initializer (ex)
  (= (expex-inline? ex)         #'%slot-value?
     (expex-move-lexicals? ex)  t
     (expex-setter-filter ex)   (compose [mapcar #'php-setter-filter _]
                                         #'expex-compiled-funcall)
     (expex-argument-filter ex) #'php-argument-filter))

(defun make-php-transpiler-0 ()
  (create-transpiler
      :name                     'php
      :lambda-export?           t
      :stack-locals?            nil
      :raw-constructor-names?   t
      :gen-string               [literal-string _ #\" (list #\$)]
	  :identifier-char?         #'php-identifier-char?
      :literal-converter        #'transpiler-expand-literal-characters
      :expex-initializer        #'php-expex-initializer))

(defun make-php-transpiler ()
  (aprog1 (make-php-transpiler-0)
	(apply #'transpiler-add-obfuscation-exceptions !
	    '(t this %funinfo false true null
		  %%native %%string
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
    (transpiler-add-defined-function ! '%cons '(a d) nil)
    (transpiler-add-defined-function ! 'phphash-hash-table '(x) nil)
    (transpiler-add-defined-function ! 'phphash-hashkeys '(x) nil)
    (transpiler-add-plain-arg-funs ! *builtins*)))

(defvar *php-transpiler* (copy-transpiler (make-php-transpiler)))
(defvar *php-newline*    (format nil "~%"))
(defvar *php-separator*  (format nil ";~%"))
(defvar *php-indent*     "    ")
