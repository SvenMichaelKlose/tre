;;;;; tré – Copyright (c) 2008–2010,2012 Sven Michael Klose <pixel@copei.de>

(defun make-bc-transpiler ()
  (aprog1 (create-transpiler
              :name 'bytecode
			  :separator (format nil ";~%")
			  :inline-exceptions (list 'bc-init)
			  :dont-inline-list '(error format replace-tree)
			  :identifier-char?
	  		      (fn (| (<= #\a _ #\z)
		  	  		     (<= #\A _ #\Z)
		  	  		     (<= #\0 _ #\9)
			  		     (in=? _ #\_ #\. #\$ #\#)))
			  :named-functions? t
			  :named-function-next #'cdddr
			  :lambda-export? t
			  :stack-locals? t
			  :rename-all-args? t
			  :literal-conversion #'identity
	          :expex-initializer #'((ex)
	                                  (= (expex-argument-filter ex) #'bc-expex-argument-filter
	                                     (expex-expr-filter ex) #'bc-expex-filter
			                             (expex-setter-filter ex) (compose (fn mapcan (fn expex-set-global-variable-value _) _)
									                                       #'expex-compiled-funcall)
		                                 (expex-inline? ex) (fn in? _ 'cons 'aref '%vec '%car '%cdr '%eq '%not))))
	(= (transpiler-inline-exceptions !) '(error format identity))))

(defvar *bc-transpiler* (copy-transpiler (make-bc-transpiler)))
(defvar *bc-separator* (transpiler-separator *bc-transpiler*))
(defvar *bc-newline* (format nil "~%"))
(defvar *bc-indent* "    ")
