;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defvar *php-version* 503)

(defun make-php-transpiler-0 ()
  (create-transpiler
      :name 'php
	  :apply-argdefs? nil
      :literal-conversion #'transpiler-expand-literal-characters
	  :identifier-char?  [| (& (>= _ #\a) (<= _ #\z))
                            (& (>= _ #\A) (<= _ #\Z))
                            (& (>= _ #\0) (<= _ #\9))
                            (in=? _ #\_ #\. #\#)]
      :gen-string [literal-string _ #\" (list #\$)]
      :lambda-export? t
      :stack-locals? nil
      :rename-all-args? t
      :inline-exceptions '(%slot-value error format identity %bind)
      :named-function-next #'cddr
      :raw-constructor-names? t
      :expex-initializer
          #'((ex)
               (= (expex-inline? ex)         #'%slot-value?
                  (expex-move-lexicals? ex)  t
    	          (expex-setter-filter ex)   (compose [mapcar [php-setter-filter *php-transpiler* _] _]
                                                      #'expex-compiled-funcall)
    	          (expex-argument-filter ex) #'php-expex-argument-filter))))

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
