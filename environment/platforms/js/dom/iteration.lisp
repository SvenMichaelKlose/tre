;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defmacro do-elements ((step iter elm &optional (ret nil)) &rest body)
  `(iterate ,iter ,step ,elm ,ret
     (& (document? ,iter)
        (return nil))
     ,@body))

(defmacro do-node-tree ((iterator root &optional (result nil)) &rest body)
  (with-gensym (vbody rec x)
    `(with (,vbody #'((,iterator)
                       ,@body)
            ,rec #'((,x)
                     (do-children (,iterator ,x)
                        (& (element? ,iterator)
                           (,rec ,iterator))
                        (,vbody ,iterator))))
       (,rec ,root)
       ,result)))

(defmacro do-element-tree ((iterator root &optional (result nil)) &rest body)
  `(do-node-tree (,iterator ,root ,result)
     (when (element? ,iterator)
       ,@body)))

(defmacro do-ancestors ((iter elm &optional (ret nil)) &rest body)
  `(do-elements ((parent-node ,iter) ,iter (parent-node ,elm) ,ret)
	 ,@body))

(defmacro do-self-and-ancestors ((iter elm &optional (ret nil)) &rest body)
  `(do-elements ((parent-node ,iter) ,iter ,elm ,ret)
	 ,@body))

(defmacro do-self-and-previous-siblings ((iter elm &optional (ret nil)) &rest body)
  `(do-elements ((slot-value ,iter 'previous-sibling) ,iter ,elm ,ret)
	 ,@body))

(defmacro do-previous-siblings ((iter elm &optional (ret nil)) &rest body)
  `(do-self-and-previous-siblings (,iter (slot-value ,elm 'previous-sibling) ,ret)
	 ,@body))

(defmacro do-self-and-next-siblings ((iter elm &optional (ret nil)) &rest body)
  `(do-elements ((slot-value ,iter 'next-sibling) ,iter ,elm ,ret)
	 ,@body))

(defmacro do-next-siblings ((iter elm &optional (ret nil)) &rest body)
  `(do-self-and-next-siblings (,iter (slot-value ,elm 'next-sibling) ,ret)
	 ,@body))

(dont-obfuscate slice)

(defmacro do-children ((iter parent &optional (result nil)) &rest body)
  `(dolist (,iter (array-list (slot-value ,parent 'child-nodes)) ,result)
     ,@body))

(mapcar-macro x '(tag class)
  (with (sby  ($ 'elements-by- x '-name)
    	 sdo  ($ 'do- sby)
    	 sget ($ 'get- sby)
	     getter `((slot-value ,,elm ',sget) ,,name))
    `(defmacro ,sdo ((iter elm name &optional (result nil)) &rest body)
       `(doarray (,,iter
			     ,(? copy?
					 `(copy-array ,getter)
					 getter)
			     ,,result)
	      ,,@body))))

(defmacro define-do-by (type)
  (with (fun-name ($ 'do-by- type)
         getter-name ($ 'caroshi-element-get-by- type))
  `(defmacro ,fun-name ((iter elm name &optional (result nil)) &rest body)
     `(dolist (,,iter
               (,getter-name ,,elm ,,name)
               ,,result)
	    ,,@body))))

(define-do-by class)
(define-do-by tag)
(define-do-by name)

(defmacro define-continue-do-by-cont (type)
  (with (fun-name ($ 'continued-do-by- type '-cont)
         getter-name ($ 'caroshi-element-get-by- type))
    `(defmacro ,fun-name (continuer next iter root name result &rest body)
       `(continued-dolist-cont ,,continuer ,,next ,,iter (,getter-name ,,root ,,name) ,,result
          ,,@body))))

(define-continue-do-by-cont class)
(define-continue-do-by-cont tag)
(define-continue-do-by-cont name)

(defmacro define-do-children-by (type)
  `(defmacro ,($ 'do-children-by- type) ((iter elm name &optional (result nil)) &rest body)
     `(dolist (,,iter
               (remove-if-not (fn ((slot-value _ ',($ 'has- (? (eq 'tag type) 'tag-name type) '?)) ,,name)) (caroshi-element-children-list ,,elm))
               ,,result)
        ,,@body)))

(define-do-children-by class)
(define-do-children-by tag)
(define-do-children-by name)

(mapcar-macro name
    `(class tag)
  (with (n ($ '-elements-by- name '-name)
		 mapper ($ 'map n)
		 looper ($ 'do n))
    `(defun ,mapper (fun root what)
       (,looper (i root what)
	     (funcall fun i)))))
