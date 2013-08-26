;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun make-javascript-transpiler-0 ()
  (create-transpiler
      :name 'js
	  :named-function-next #'cdr
	  :apply-argdefs? t
	  :identifier-char? [| (& (>= _ #\a) (<= _ #\z))
                           (& (>= _ #\A) (<= _ #\Z))
                           (& (>= _ #\0) (<= _ #\9))
                           (in=? _ #\_ #\. #\$ #\#)]
	  :lambda-export? nil
	  :continuation-passing-style? t
	  :needs-var-declarations? t
	  :stack-locals? nil
	  :rename-all-args? t
	  :rename-toplevel-function-args? t
	  :literal-conversion #'transpiler-expand-literal-characters
      :expex-initializer 
          #'((ex)
               (= (expex-setter-filter ex)   #'expex-collect-wanted-variable
                  (expex-argument-filter ex) #'expex-%setq-collect-wanted-global-variable))))

(defun make-javascript-transpiler ()
  (aprog1 (make-javascript-transpiler-0)
	(apply #'transpiler-add-obfuscation-exceptions !
	    '(t this %funinfo false true null delete
		  %%native %%string
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

		  alert
          
          focus disabled match escape))
    (transpiler-add-plain-arg-funs ! *builtins*)))

(defvar *js-transpiler* (copy-transpiler (make-javascript-transpiler)))
(defvar *js-newline*    (format nil "~%"))
(defvar *js-separator*  (format nil ";~%"))
(defvar *js-indent*     "    ")
