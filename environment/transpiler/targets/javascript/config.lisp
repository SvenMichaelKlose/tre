;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun js-expex-initializer (ex)
  (= (expex-inline? ex)         #'%slot-value?
     (expex-argument-filter ex) #'js-argument-filter))

(defun make-javascript-transpiler-0 ()
  (create-transpiler
      :name                     'js
      :prologue-gen             #'js-prologue
      :epilogue-gen             #'js-epilogue
      :decl-gen                 #'js-decl-gen
      :sections-before-deps     #'js-sections-before-deps
      :sections-after-deps      #'js-sections-after-deps
	  :lambda-export?           nil
	  :stack-locals?            nil
	  :needs-var-declarations?  t
	  :identifier-char?         #'c-identifier-char?
	  :literal-converter        #'transpiler-expand-literal-characters
      :expex-initializer        #'js-expex-initializer
      :count-tags?              t))

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
(defvar *js-separator*  (+ ";" *newline*))
(defvar *js-indent*     "    ")
