;;;;; tré – Copyright (c) 2008–2010,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun make-bc-transpiler ()
  (aprog1 (create-transpiler
              :name 'bytecode
			  :separator (format nil ";~%")
			  :identifier-char?
	  		      [| (<= #\a _ #\z)
		  	  		 (<= #\A _ #\Z)
		  	  		 (<= #\0 _ #\9)
			  		 (in=? _ #\_ #\. #\$ #\#)]
			  :lambda-export? t
			  :stack-locals? t
			  :arguments-on-stack? t
			  :literal-conversion #'identity
	          :expex-initializer #'((ex)
	                                  (= (expex-argument-filter ex) #'bc-expex-argument-filter
			                             (expex-setter-filter ex) (compose [mapcan [expex-set-global-variable-value _] _]
									                                       #'expex-compiled-funcall)))
              :code-concatenator #'((&rest x) (tree-list x))
              :make-text? nil
              :encapsulate-strings? nil
              :function-name-prefix nil
              :function-prologues? nil)
    (transpiler-add-plain-arg-funs ! *builtins*)))

(defvar *bc-transpiler* (copy-transpiler (make-bc-transpiler)))
(defvar *bc-separator*  (transpiler-separator *bc-transpiler*))
(defvar *bc-newline*    (format nil "~%"))
(defvar *bc-indent*     "    ")
