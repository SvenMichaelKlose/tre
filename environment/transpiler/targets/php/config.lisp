;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun php-identifier-char? (x)
  (unless (== #\$ x)
    (c-identifier-char? x)))

(defun php-expex-initializer (ex)
  (= (expex-inline? ex)         #'%slot-value?
     (expex-setter-filter ex)   (compose [mapcar #'php-setter-filter _]
                                         #'expex-compiled-funcall)
     (expex-argument-filter ex) #'php-argument-filter))

(defun make-php-transpiler-0 ()
  (create-transpiler
      :name                     'php
      :frontend-init            #'php-frontend-init
      :prologue-gen             #'php-prologue
      :epilogue-gen             #'php-epilogue
      :decl-gen                 #'php-decl-gen
      :sections-before-deps     #'php-sections-before-deps
      :sections-after-deps      #'php-sections-after-deps
      :lambda-export?           t
      :stack-locals?            nil
      :gen-string               [literal-string _ #\" (list #\$)]
	  :identifier-char?         #'php-identifier-char?
      :literal-converter        #'transpiler-expand-literal-characters
      :expex-initializer        #'php-expex-initializer))

(defun make-php-transpiler ()
  (aprog1 (make-php-transpiler-0)
    (transpiler-add-defined-function ! '%cons '(a d) nil)
    (transpiler-add-defined-function ! 'phphash-hash-table '(x) nil)
    (transpiler-add-defined-function ! 'phphash-hashkeys '(x) nil)
    (transpiler-add-plain-arg-funs ! *builtins*)))

(defvar *php-transpiler* (copy-transpiler (make-php-transpiler)))
(defvar *php-newline*    (format nil "~%"))
(defvar *php-separator*  (format nil ";~%"))
(defvar *php-indent*     "    ")
