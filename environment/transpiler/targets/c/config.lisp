;;;;; tré – Copyright (c) 2008–2010,2012 Sven Michael Klose <pixel@copei.de>

(defun make-c-transpiler ()
  (aprog1 (create-transpiler
              :name 'c
			  :separator (format nil ";~%")
			  :inline-exceptions '(c-init error format replace-tree)
			  :identifier-char?
	  		      [| (<= #\a _ #\z)
		  	  	     (<= #\A _ #\Z)
		  	  	     (<= #\0 _ #\9)
			  	     (in=? _ #\_ #\. #\$ #\#)]
			  :named-functions? t
			  :named-function-next #'cdddr
			  :lambda-export? t
			  :stack-locals? t
			  :copy-arguments-to-stack? t
			  :rename-all-args? t
			  :literal-conversion #'identity
	          :expex-initializer #'((ex)
	                                 (= (expex-argument-filter ex) #'c-expex-argument-filter
	                                    (expex-expr-filter ex) #'c-expex-filter
			                            (expex-setter-filter ex) (compose [mapcan [expex-set-global-variable-value _] _]
									                                      #'expex-compiled-funcall)
		                                (expex-inline? ex) [in? _ 'cons 'aref '%vec '%car '%cdr '%eq '%not])))
	(= (transpiler-inline-exceptions !) '(error format identity))))

(defvar *c-transpiler* (copy-transpiler (make-c-transpiler)))
(defvar *c-separator* (transpiler-separator *c-transpiler*))
(defvar *c-newline* (format nil "~%"))
(defvar *c-indent* "    ")
