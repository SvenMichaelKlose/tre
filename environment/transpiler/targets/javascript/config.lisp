; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(defun js-expex-initializer (ex)
  (= (expex-inline? ex)         #'%slot-value?
     (expex-argument-filter ex) #'js-argument-filter))

(defun make-javascript-transpiler-0 ()
  (create-transpiler
      :name                     'js
      :prologue-gen             #'js-prologue
      :epilogue-gen             #'js-epilogue
      :decl-gen                 #'js-var-decls
      :sections-before-deps     #'js-sections-before-deps
      :sections-after-deps      #'js-sections-after-deps
	  :lambda-export?           nil
	  :stack-locals?            nil
	  :needs-var-declarations?  t
      :count-tags?              t
	  :identifier-char?         #'c-identifier-char?
	  :literal-converter        #'expand-literal-characters
      :expex-initializer        #'js-expex-initializer
      :ending-sections          #'js-ending-sections
      :configurations           '((environment       . browser)
                                  (nodejs-requirements . nil)
                                  (rplac-breakpoints . nil))))

(defun make-javascript-transpiler ()
  (aprog1 (make-javascript-transpiler-0)
    (transpiler-add-plain-arg-funs ! *builtins*)))

(defvar *js-transpiler* (copy-transpiler (make-javascript-transpiler)))
(| *default-transpiler*
   (= *default-transpiler* *js-transpiler*))
(defvar *js-separator*  (+ ";" *newline*))
(defvar *js-indent*     "    ")
